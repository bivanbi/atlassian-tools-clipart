#!/bin/bash
set -eou pipefail
DIR="$(dirname "${0}")"
SRC_DIR="${DIR}/src"
TARGET_DIR="${DIR}/target"

CROWD_HELPER="crowd_helper"
CHROME_EXTENSION="chrome_extension"

CHROME_EXTENSION_ICON_SOURCE_SUFFIX="-${CHROME_EXTENSION}-icon.svg"
FAVICON_SOURCE_SUFFIX="-favicon.svg"

CHROME_EXTENSION_ICON_SIZES="16 32 48 128"
FAVICON_SIZES="16 32 48"

APPS="${CROWD_HELPER}"

function get_app_target_dir() {
  local app_name="${1}"
  echo "${TARGET_DIR}/${app_name}"
}

function generate_chrome_extension_icon_png() {
  local target_dir="${1}"
  local app_name="${2}"

  for size in ${CHROME_EXTENSION_ICON_SIZES}; do
    local svg_filepath="${SRC_DIR}/${app_name}/${app_name}${CHROME_EXTENSION_ICON_SOURCE_SUFFIX}"
    local png_filepath="${target_dir}/${app_name}${size}.png"
    convert -background none -resize "${size}x${size}!" "${svg_filepath}" "${png_filepath}"
    echo "Generated ${png_filepath}"
  done
}

function generate_favicon_source_png() {
  local target_dir="${1}"
  local app_name="${2}"
  local size="${3}"

  local svg_filepath="${SRC_DIR}/${app_name}/${app_name}${FAVICON_SOURCE_SUFFIX}"
  local png_filepath="${target_dir}/favicon${size}.png"
  convert -background none -resize "${size}x${size}!" "${svg_filepath}" "${png_filepath}"
  echo "${png_filepath}"
}

function generate_favicon() {
  local target_dir="${1}"
  local app_name="${2}"
  local png_file_list=""

  for size in ${FAVICON_SIZES}; do
    echo "Building favicon png size ${size}"
    local png_filepath
    png_filepath="$(generate_favicon_source_png "${target_dir}" "${app_name}" "${size}")"
    echo "built favicon png ${png_filepath}"
    png_file_list="${png_file_list} ${png_filepath}"
  done

  echo "File list: '${png_file_list}'"
  target_ico="${target_dir}/favicon.ico"
  convert -background none ${png_file_list} "${target_ico}"
  rm ${png_file_list}
  echo "Generated ${target_ico}"
}

function generate_chrome_images() {
  local target_dir="${1}"
  local app_name="${2}"
  mkdir -p "${target_dir}"
  echo convert -background none -resize "440x280!" "${SRC_DIR}/${app_name}/${app_name}-chrome_web_store-promo.svg" "${target_dir}/${app_name}-chrome_web_store-promo.png"
  convert -background none -resize "440x280!" "${SRC_DIR}/${app_name}/${app_name}-chrome_web_store-promo.svg" "${target_dir}/${app_name}-chrome_web_store-promo.png"
}

function copy_svg_images_to_target() {
  local target_dir="${1}"
  local app_name="${2}"
  cp "${SRC_DIR}/${app_name}"/*svg ${target_dir}
}

for app_name in ${APPS}; do
  target_dir="$(get_app_target_dir "${app_name}")"
  mkdir -p "$(get_app_target_dir "${app_name}")"
  generate_chrome_extension_icon_png "${target_dir}" "${app_name}"
  generate_favicon "${target_dir}" "${app_name}"
  generate_chrome_images "${target_dir}" "${app_name}"
  copy_svg_images_to_target "${target_dir}" "${app_name}"
done
