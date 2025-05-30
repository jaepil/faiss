/*
 * Copyright (c) Meta Platforms, Inc. and affiliates.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#pragma once

#include <faiss/gpu/utils/Pair.cuh>
#include <limits>

namespace faiss {
namespace gpu {

template <typename T>
struct Limits {};

// Unfortunately we can't use constexpr because there is no
// constexpr constructor for half
// FIXME: faiss CPU uses +/-FLT_MAX instead of +/-infinity
constexpr float kFloatMax = std::numeric_limits<float>::max();
constexpr float kFloatMin = std::numeric_limits<float>::lowest();

template <>
struct Limits<float> {
    static __device__ __host__ inline float getMin() {
        return kFloatMin;
    }
    static __device__ __host__ inline float getMax() {
        return kFloatMax;
    }
};

inline __device__ __host__ half kGetHalf(unsigned short v) {
#if CUDA_VERSION >= 9000 || defined(USE_AMD_ROCM)
    __half_raw h;
    h.x = v;
    return __half(h);
#else
    half h;
    h.x = v;
    return h;
#endif
}

template <>
struct Limits<half> {
    static __device__ __host__ inline half getMin() {
        return kGetHalf(0xfbffU);
    }
    static __device__ __host__ inline half getMax() {
        return kGetHalf(0x7bffU);
    }
};

constexpr int kIntMax = std::numeric_limits<int>::max();
constexpr int kIntMin = std::numeric_limits<int>::lowest();

template <>
struct Limits<int> {
    static __device__ __host__ inline int getMin() {
        return kIntMin;
    }
    static __device__ __host__ inline int getMax() {
        return kIntMax;
    }
};

constexpr idx_t kIdxTMax = std::numeric_limits<idx_t>::max();
constexpr idx_t kIdxTMin = std::numeric_limits<idx_t>::lowest();

template <>
struct Limits<idx_t> {
    static __device__ __host__ inline idx_t getMin() {
        return kIdxTMin;
    }
    static __device__ __host__ inline idx_t getMax() {
        return kIdxTMax;
    }
};

template <typename K, typename V>
struct Limits<Pair<K, V>> {
    static __device__ __host__ inline Pair<K, V> getMin() {
        return Pair<K, V>(Limits<K>::getMin(), Limits<V>::getMin());
    }

    static __device__ __host__ inline Pair<K, V> getMax() {
        return Pair<K, V>(Limits<K>::getMax(), Limits<V>::getMax());
    }
};

} // namespace gpu
} // namespace faiss
