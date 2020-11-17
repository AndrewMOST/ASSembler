#include <stdexcept>
#include <string>
#include <thread>
#include <unordered_set>
#include <iostream>
#include <vector>
#include <utility>
#include <mutex>
#include <chrono>

std::mutex mtx;
size_t lower = 1e3;
size_t upper = 1e9;

void SameDigits(size_t multiplicant, size_t lower, size_t upper);

int main(int argc, char* argv[]) {
	if (argc != 3) throw std::runtime_error("Two console parameters expected");

	size_t multiplicant = std::stoi(argv[1]);
	if (multiplicant < 2 || multiplicant > 9) throw std::invalid_argument("Multiplication argument should be bigger than 1 and less than 10");

	size_t num_of_threads = std::stoi(argv[2]);
	if (num_of_threads < 1 || num_of_threads >= 1000) throw std::invalid_argument("Number of threads should be positive and not exceed 100");
	size_t nums_per_thread = (upper - lower - 1) / num_of_threads;

	// Засекаем время
	auto start = std::chrono::high_resolution_clock::now();

	// Перенаправляем вывод
	freopen("./output.txt", "w", stdout);

	std::vector<std::thread> threads;

	// Инициализируем потоки
	for (size_t i = 0; i < num_of_threads - 1; i++)
	{
		std::thread thr(SameDigits, multiplicant, lower + i * nums_per_thread, lower + (i + 1) * nums_per_thread);
		// std::cout << (int64_t) (lower + i * nums_per_thread) << " " << (int64_t) (lower + (i + 1) * nums_per_thread) << std::endl;
		threads.emplace_back(std::move(thr));
	}

	std::thread thr(SameDigits, multiplicant, lower + (num_of_threads - 1) * nums_per_thread, upper);
    // std::cout << (int64_t) (lower + (num_of_threads - 1) * nums_per_thread) << " " << (int64_t) (upper) << std::endl;
	threads.emplace_back(std::move(thr));

	// Джоин
	for (auto& thr : threads) {
		thr.join();
	}

	// Отсечка времени
	auto finish = std::chrono::high_resolution_clock::now();
	std::chrono::duration<double> elapsed = finish - start;
	std::cout << "Elapsed time: " << elapsed.count() << std::endl;
}

void SameDigits(size_t multiplicant, size_t lower, size_t upper) {
	for (size_t i = lower; i < upper; i++)
	{
		// Получаем цифры текущего числа
		size_t cur = i;
		std::unordered_set<uint8_t> digits;
		while (cur != 0) {
			digits.insert(cur % 10);
			cur /= 10;
		}

		// Цифры, которые уже использованы в произведении
		std::unordered_set<size_t> used;

		// Умножаем
		cur = i * multiplicant;
		bool nice = true;

		// Если цифра есть в исходном числе, убираем оттуда, добавляем в использованные
		// Если нет ни в исходных, ни в использованных, значит число неподходящее
		while (cur != 0) {
			size_t rem = cur % 10;
			if (digits.count(rem)) {
				digits.erase(rem);
				used.insert(rem);
			}
			else if (!used.count(rem)) {
				nice = false;
				break;
			}
			cur /= 10;
		}

		if (!(nice && digits.size() == 0)) continue;

		printf("%lu\n", i);
	}
}
