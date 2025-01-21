from __future__ import annotations

from collections import Counter

from PIL import Image
from patchify import patchify
from pathlib import Path
import fire
import numpy as np
import numpy.typing as npt


def png_to_patch_bytes(image: Image.Image, rows: int) -> list[bytes]:
    image = image.quantize(colors=4, dither=Image.Dither.NONE)
    # (h, w)
    image_arr = np.asarray(image)
    # (h/8, w/8, 8, 8)
    patches = patchify(image_arr, (8, 8), step=8)
    if rows > 0:
        patches = patches[:rows]
    
    exp2 = np.array([128, 64, 32, 16, 8, 4, 2, 1], dtype=np.uint8)
    # (h/8, w/8, 8) (h/8, w/8, 8)
    lower_byte = (patches % 2) @ exp2
    upper_byte = (patches // 2) @ exp2
    patches_h, patches_w = patches.shape[:2]
    # (h/8, w/8, 8, 2)
    patch_byte_arr = np.stack([lower_byte, upper_byte], axis=3)
    # (h/8 * w/8, 16)
    patch_byte_arr = patch_byte_arr.reshape(-1, 16)
    patch_bytes = np.apply_along_axis(lambda row: row.tobytes(), 1, patch_byte_arr)

    return patch_bytes.astype("void").tolist()

def patch_diff(patch_i: bytes, patch_j: bytes) -> int:
    # Returns the pixel difference between two patches. A patch of 8x8 pixels is represented as 16 bytes
    # Each row of 8 pixels is represented as two bytes, where the lower byte contains (v % 2) and the upper byte
    # contains (v // 2) for each pixel value v in left-to-right order.
    diff = 0
    for row_index in range(len(patch_i) // 2):
        li, ui = patch_i[2 * row_index: 2 * row_index + 2]
        lj, uj = patch_j[2 * row_index: 2 * row_index + 2]
        lower_xor = li ^ lj
        upper_xor = ui ^ uj
        carry = (li & ~ui & ~lj & uj) | (~li & ui & lj & ~uj)
        diff += lower_xor.bit_count() + upper_xor.bit_count() * 2 - carry.bit_count()
    return diff

def compress_patches(patches: list[bytes], allowed_unique_patches: int) -> list[bytes]:
    def _diff(patch_i: bytes, patch_j: bytes) -> int:
        # TODO: distance metric based on pixel value instead of bit representation
        return sum((byte_i ^ byte_j).bit_count() for byte_i, byte_j in zip(patch_i, patch_j))

    patch_counter: dict[bytes, int] = Counter(patches)
    unique_patches: list[bytes] = list(patch_counter.keys())

    num_unique_patches = len(unique_patches)
    if num_unique_patches <= allowed_unique_patches:
        return patches

    patch_counts = np.array(list(patch_counter.values()))

    patch_diffs = np.zeros((num_unique_patches, num_unique_patches))
    for i in range(num_unique_patches):
        # Set difference between patch and itself to max to exclude from selection
        patch_diffs[i, i] = 255
        for j in range(i+1, num_unique_patches):
            diff = patch_diff(unique_patches[i], unique_patches[j])
            patch_diffs[i, j] = patch_diffs[j, i] = diff

    costs = np.empty((num_unique_patches, num_unique_patches))

    idx2patch: dict[int, bytes] = {i: b for i, b in enumerate(unique_patches)}
    patch2patch: dict[bytes, bytes] = {b: b for b in unique_patches}
    active: npt.NDArray = np.ones((num_unique_patches,), dtype=bool)
    for step in range(num_unique_patches - allowed_unique_patches):
        costs[:] = patch_diffs * patch_counts[:, np.newaxis]
        costs[~active] = np.inf
        costs[:,~active] = np.inf
        # costs[i, j] = {
        #   inf                         if i or j inactive
        #   patch_diff(i, j) * count(i) else
        # }
        # is the cost of replacing patch i with patch j
        min_cost_in_flattened = np.argmin(costs)
        target = min_cost_in_flattened // num_unique_patches
        source = min_cost_in_flattened % num_unique_patches
        # replace patch target with patch source
        source_patch = idx2patch[source]
        target_patch = idx2patch[target]
        patch2patch[target_patch] = source_patch
        active[target] = False
        patch_counts[source] += patch_counts[target]
        patch_counts[target] = 0

    def _flatten(patch: bytes) -> bytes:
        if patch2patch[patch] == patch:
            return patch
        patch2patch[patch] = _flatten(patch2patch[patch])
        return patch2patch[patch]

    for patch in unique_patches:
        _flatten(patch)

    compressed_patches: list[bytes] = [patch2patch[patch] for patch in patches]
    return compressed_patches


def save_tilemap_and_2bpp(patches: list[bytes], output_2bpp_path: str, output_tilemap_path: str) -> None:
    patch2idx: dict[bytes, bytes] = {}
    with open(output_2bpp_path, "wb") as tile_file, open(output_tilemap_path, "wb") as tilemap_file:
        for patch_bytes in patches:
            if patch_bytes not in patch2idx:
                if len(patch2idx) >= 256:
                    raise ValueError("Found >256 unique patches.")
                patch2idx[patch_bytes] = len(patch2idx).to_bytes(1, "little")
                tile_file.write(patch_bytes)
            idx: bytes = patch2idx[patch_bytes]
            tilemap_file.write(idx)
    print(f"Wrote {output_2bpp_path} and {output_tilemap_path} ({len(patch2idx)} unique patches)")


def generate_tilemap_and_2bpp(
    input_png_path: str,
    output_2bpp_path: str,
    output_tilemap_path: str,
    allowed_unique_patches: int,
    rows: int = -1,
) -> None:
    print(f"{input_png_path=}")
    print(f"{output_2bpp_path=}")
    print(f"{output_tilemap_path=}")
    print(f"{allowed_unique_patches=}")

    assert output_2bpp_path.endswith(".2bpp")
    assert output_tilemap_path.endswith(".tilemap")

    Path(output_2bpp_path).parent.mkdir(parents=True, exist_ok=True)
    Path(output_tilemap_path).parent.mkdir(parents=True, exist_ok=True)

    image: Image.Image = Image.open(input_png_path)
    patches: list[bytes] = png_to_patch_bytes(image, rows)
    patches = compress_patches(patches, allowed_unique_patches)
    save_tilemap_and_2bpp(patches, output_2bpp_path, output_tilemap_path)


if __name__ == "__main__":
    fire.Fire(generate_tilemap_and_2bpp)
