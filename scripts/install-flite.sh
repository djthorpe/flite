#!/bin/bash
# Script to compile flite speech-to-text and download
# additional voices
#
# Author: David Thorpe <djt@mutablelogic.com>
#
# Usage:
#   install-flite.sh [-f] [-p prefix]
#
# Flag -f will remove any existing installations first
#      -p will determine where flite is installed
#####################################################################

# This is the URL for the ZIP distribution
FLITE_VERSION="2.1.0"
FLITE_URL="third_party/flite-${FLITE_VERSION}.tar.gz"

# PREFIX is the parent directory of the installation
PREFIX="/opt"
# FORCE set to 1 will result in any existing installation being
# removed first
FORCE=0

#####################################################################
# PROCESS FLAGS

while getopts 'fp:' FLAG ; do
  case ${FLAG} in
    f)
	  FORCE=1
      ;;
    u)
	  PREFIX=${OPTARG}
      ;;      
    \?)
      echo "Invalid option: -${OPTARG}"
	  exit 1
      ;;
  esac
done

#####################################################################
# CHECKS

# Temporary location
TEMP_DIR=`mktemp -d`
if [ ! -d "${TEMP_DIR}" ]; then
  echo "Missing temporary directory: ${TEMP_DIR}"
  exit 1
fi

# Ensure we have curl and patch
CURL_BIN=`which curl`
if [ ! -x "${CURL_BIN}" ] ; then
  echo "Missing curl"
  exit 1
fi

PATCH_BIN=`which patch`
if [ ! -x "${PATCH_BIN}" ] ; then
  echo "Missing patch"
  exit 1
fi

#####################################################################
# DOWNLOAD AND INSTALL

CURRENT_PATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
BASE_PATH="${CURRENT_PATH}/.."
DIST_FILENAME="${BASE_PATH}/${FLITE_URL}"

# Check prefix directory is writable
if [ ! -w "${PREFIX}" ] ; then
  echo "${PREFIX}: Mot writable"
  exit 1
fi

# Ensure the distribution exists
if [ ! -f "${DIST_FILENAME}"  ] ; then
  echo "Not found: ${FLITE_URL}"
  rm -fr "${TEMP_DIR}"
  exit 2
fi

# Unarchive and obtain the folder name
echo "Unarchiving ${FLITE_URL}"
tar -C "${TEMP_DIR}" -zxf "${DIST_FILENAME}"
FLITE_PATHNAME=`find "${TEMP_DIR}" -maxdepth 1 -mindepth 1 -type d -print`
if [ ! -d "${FLITE_PATHNAME}" ] ; then
  echo "Cannot unpack distribution"
  rm -fr "${TEMP_DIR}"
  exit 2
fi

# Apply the patch
cd "${FLITE_PATHNAME}"
if [ -f "${BASE_PATH}/third_party/flite-2.1.0.patch" ] ; then
  if ! ${PATCH_BIN} main/Makefile "${BASE_PATH}/third_party/flite-2.1.0.patch" ; then
    echo "Error performing configuration, exit code $?"
    rm -fr "${TEMP_DIR}"
    exit 2
  fi
fi

# Configure, make and install
FLITE_BASENAME=`basename "${FLITE_PATHNAME}"`
if ! ./configure --prefix="${PREFIX}/${FLITE_BASENAME}" ; then 
  echo "Error performing configuration, exit code $?"
  rm -fr "${TEMP_DIR}"
  exit 2
else  
  make && make install
fi

cd "${PREFIX}" || exit 3
if [ -d "${PREFIX}/flite" ] ; then
    rm "${PREFIX}/flite" || exit 3
fi
ln -s "${PREFIX}/${FLITE_BASENAME}" flite || exit 3
rm -fr "${TEMP_DIR}" || exit 3

#####################################################################
# GET VOICES

function download_voices {
    FLITE_VOICEDIR_URL="http://cmuflite.org/packed/flite-2.1/voices"
    FLITE_TYPE=$1   

    echo "Downloading ${FLITE_TYPE}"
    cd "${PREFIX}/flite"
    install -d voices || return 4
    cd voices && curl -L -o ${FLITE_TYPE} "${FLITE_VOICEDIR_URL}/${FLITE_TYPE}" || return 4
    for i in `grep ".flitevox$" ${FLITE_TYPE}`
    do
        VOICE_FILENAME=`basename $i`
        if [ ! -f "${VOICE_FILENAME}" ] ; then
            echo "Downloading: ${VOICE_FILENAME}"
            curl -L -s -o "${VOICE_FILENAME}" "${FLITE_VOICEDIR_URL}/${VOICE_FILENAME}" || return 4
        fi
    done
    return 0
}

if ! download_voices "us_voices" ; then
  echo "Error downloading US Voices"
fi
if ! download_voices "indic_voices" ; then
  echo "Error downloading Indic Voices"
fi

#####################################################################
# SUCESS

echo "Finished, installed: ${PREFIX}/${FLITE_BASENAME}"
exit 0
