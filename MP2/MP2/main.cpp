#include <iostream>
#include <thread>
#include <vector>
#include <mutex>
#include <stdexcept>
#include <chrono>

using MutexPtr = std::shared_ptr<std::mutex>;
auto start = std::chrono::high_resolution_clock::now();

class Room {
public:
    Room(bool is_single) : is_single_(is_single) {
    }

    bool CanAccept(bool is_male) {
        int other_sex = is_male ? 2 : 1;
        if (is_single_) return male_or_female_ != other_sex && number_of_occupants_ == 0;
        else return male_or_female_ != other_sex && number_of_occupants_ < 2;
    }

    void Accept(bool is_male) {
        if (!CanAccept(is_male)) throw std::runtime_error("Can not accept this person!");

        male_or_female_ = is_male ? 1 : 2;
        number_of_occupants_++;
    }

    void Clear() {
        male_or_female_ = 0;
        number_of_occupants_ = 0;
    }

private:
    friend class Hotel;
    int male_or_female_ = 0;
    bool is_single_;
    int number_of_occupants_ = 0;
};

class Hotel {
public:
    Hotel() {
        for (int i = 0; i < 10; ++i) {
            rooms_.emplace_back(std::make_pair(Room(true), std::make_shared<std::mutex>()));
        }

        for (int i = 0; i < 15; ++i) {
            rooms_.emplace_back(std::make_pair(Room(false), std::make_shared<std::mutex>()));
        }
    }

    int Accept(bool is_male) {
        bool res = false;
        for (int i = 0; i < rooms_.size(); ++i) {
            rooms_[i].second->lock();
            if (rooms_[i].first.CanAccept(is_male)) {
                rooms_[i].first.Accept(is_male);
                res = true;
            }
            rooms_[i].second->unlock();

            if (res) return i + 1;
        }

        return -1;
    }

    void Clear() {
        for (int i = 0; i < rooms_.size(); ++i) {
            rooms_[i].first.Clear();
        }
    }

private:
    std::vector<std::pair<Room, MutexPtr>> rooms_;
};

void insideThread(int thread_num, int num_of_customers, Hotel* hotel) {
    for (int i = 0; i < num_of_customers; ++i) {
        bool is_male = rand() % 2;

        int room = hotel->Accept(is_male);
        int time = std::chrono::duration_cast<std::chrono::microseconds>(std::chrono::system_clock::now() - start).count();
        if (room != -1) {
            if (is_male) printf("Elapsed: %d μs. Thread %d: Man number %d has checked into the hotel room number %d.\n", time, thread_num + 1, i + 1, room);
            else printf("Elapsed: %d μs. Thread %d: Woman number %d has checked into the hotel room number %d.\n", time, thread_num + 1, i + 1, room);
        } else {
            if (is_male) printf("Elapsed: %d μs. Thread %d: Man number %d went to look somewhere else.\n", time, thread_num + 1, i + 1);
            else printf("Elapsed: %d μs. Thread %d: Woman number %d went to look somewhere else.\n", time, thread_num + 1, i + 1);
        }
    }
}

int main(int argc, char **argv) {
    if (argc != 4) throw std::invalid_argument("Incorrect number of command line arguments!");
    srand(time(nullptr));
    start = std::chrono::high_resolution_clock::now();

    Hotel hotel;

    int num_of_threads = std::stoi(argv[1]);
    int people_per_thread = std::stoi(argv[2]);
    int nights = std::stoi(argv[3]);
    if (num_of_threads < 1 || num_of_threads > 50 || people_per_thread < 1
            || people_per_thread > 50 || nights < 1 || nights > 50)
        throw std::invalid_argument("Invalid values!");

    for (int i = 0; i < nights; ++i) {
        std::vector<std::thread> threads;
        for (int i = 0; i < num_of_threads; ++i) {
            std::thread thr(insideThread, i, people_per_thread, &hotel);
            threads.emplace_back(std::move(thr));
        }

        for (auto& thr : threads) {
            thr.join();
        }

        hotel.Clear();
        printf("\nNight %d has ended. Everybody leaves the hotel.\n\n", i + 1);
    }
}
