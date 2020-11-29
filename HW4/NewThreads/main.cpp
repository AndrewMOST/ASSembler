#include <stdexcept>
#include <string>
#include <thread>
#include <unordered_set>
#include <iostream>
#include <utility>
#include <chrono>
#include <omp.h>

size_t lower = 1e3;
size_t upper = 1e9;

void SameDigits(size_t i, size_t multiplicant);

int main(int argc, char* argv[]) {
    if (argc != 2) throw std::runtime_error("One console parameter expected");

    size_t multiplicant = std::stoi(argv[1]);
    if (multiplicant < 2 || multiplicant > 9) throw std::invalid_argument("Multiplication argument should be bigger than 1 and less than 10");

    // Засекаем время
    auto start = std::chrono::high_resolution_clock::now();

    // Перенаправляем вывод
    freopen("./output.txt", "w", stdout);

#pragma omp parallel for
    for (size_t i = lower; i < upper; ++i) {
        SameDigits(i, multiplicant);
    }

    // Отсечка времени
    auto finish = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double> elapsed = finish - start;
    std::cout << "Elapsed time: " << elapsed.count() << std::endl;
}

void SameDigits(size_t i, size_t multiplicant) {
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

    if (nice && digits.size() == 0) printf("%lu\n", i);
}
