#!/bin/bash

set -e

# Specify options
usage() { echo "Usage: $0 -b <chrome|firefox> PATH_TO_EXTENSION_ROOT" 1>&2; exit 1; }

while getopts ":e:b:" opt; do
    case "${opt}" in
        k)
            key_path=${OPTARG}
            ;;
        b)
            browser=${OPTARG}
            [ $browser == "chrome" -o $browser == "firefox" ] || usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

path=$1

if [ -z "${path}" ] || [ -z "${browser}" ]; then
  usage
fi

path=${1%/}

#$(${path}/bin/buildManifest.sh -b ${browser} ${path})

rm -f $path/build/filmweb-ratings.crx

if [ $browser == "chrome" ]; then
  key=$key_path

  echo "Key path: ${key_path}"
  if [ ! $key ] || [ ! -f $key ]; then
    echo "The key doesn't exists at the path: ${key_path}"
    usage
  fi

  name="filmweb-ratings"
  crx="$name.crx"
  pub="$name.pub"
  sig="$name.sig"
  zip="$name.zip"
  trap 'rm -f "$pub" "$sig" "$zip"' EXIT

  # zip up the crx dir
  cwd=$(pwd -P)
  (cd "$path" && zip -qr -9 -X "$cwd/$zip" .)

  # signature
  openssl sha1 -sha1 -binary -sign "$key" < "$zip" > "$sig"

  # public key
  openssl rsa -pubout -outform DER < "$key" > "$pub" 2>/dev/null

  byte_swap () {
    # Take "abcdefgh" and return it as "ghefcdab"
    echo "${1:6:2}${1:4:2}${1:2:2}${1:0:2}"
  }

  crmagic_hex="4372 3234" # Cr24
  version_hex="0200 0000" # 2
  pub_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "$pub" | awk '{print $5}')))
  sig_len_hex=$(byte_swap $(printf '%08x\n' $(ls -l "$sig" | awk '{print $5}')))
  (
    echo "$crmagic_hex $version_hex $pub_len_hex $sig_len_hex" | xxd -r -p
    cat "$pub" "$sig" "$zip"
  ) > "$path/build/$crx"
  echo "The extension has been created: '$path/build/$crx'"
fi

if [ $browser == "firefox" ]; then
  cd ${path} && zip -r -FS $path/build/filmweb-ratings.xpi *

  echo "The extension has been created: '$path/build/filmweb-ratings.xpi'"
fi
