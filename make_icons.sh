#!/bin/bash
set -eou pipefail
DIR="$(dirname $0)"
SRC_DIR="${DIR}/src"
TARGET_DIR="${DIR}/target"

APPS="crowd_helper"
ICON_SIZES="16 32 48 128"
FAVICON_SIZES="16 32 48"

function get_app_target_dir()
{
	local app_name="${1}"
	echo "${TARGET_DIR}/${app_name}"
}

function make_target_dir()
{
	local app_name="${1}"
	mkdir -p "$(get_app_target_dir "${app_name}")"
}

function generate_png_filepath()
{
	local app_name="${1}"
	local size="${2}"
	local target_dir="$(get_app_target_dir "${app_name}")"
	echo "${target_dir}/${app_name}${size}.png"
}

function generate_png()
{
	local app_name="${1}"

	for size in ${ICON_SIZES}
	do
		local svg_filepath="${SRC_DIR}/${app_name}.svg"
		local png_filepath="$(generate_png_filepath "${app_name}" "${size}")"
		convert -size ${size}x${size} ${svg_filepath} ${png_filepath}
		echo "Generated ${png_filepath}"
	done	
}

function generate_favicon()
{
	local app_name="${1}"
	local png_file_list=""

	for size in ${FAVICON_SIZES}
	do
		local png_filepath="$(generate_png_filepath "${app_name}" "${size}")"
		png_file_list="${png_file_list} ${png_filepath}"
	done

	local target_dir="$(get_app_target_dir "${app_name}")"
	convert ${png_file_list} "${target_dir}/${app_name}.ico"
	echo "Generated ${target_dir}/${app_name}.ico"
}

function get_app_list()
{
	find "${TARGET_DIR}" -mindepth 1 -maxdepth 1 -exec basename {} \;
}

for app_name in ${APPS}
do
	make_target_dir "${app_name}"
    generate_png "${app_name}"
    generate_favicon "${app_name}"
done
