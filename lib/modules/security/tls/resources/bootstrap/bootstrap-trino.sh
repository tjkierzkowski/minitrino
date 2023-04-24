#!/usr/bin/env bash

set -euxo pipefail

echo "Setting variables..."
TRUSTSTORE_PATH=/etc/pki/java/cacerts
TRUSTSTORE_DEFAULT_PASS=changeit
TRUSTSTORE_PASS=trinoRocks15
KEYSTORE_PASS=trinoRocks15
SSL_DIR=/etc/starburst/ssl

echo "Removing pre-existing SSL resources..."
rm -f "${SSL_DIR}"/* 
echo "Generating keystore file..."
keytool -genkeypair \
	-alias trino \
	-keyalg RSA \
	-keystore "${SSL_DIR}"/keystore.jks \
	-keypass "${KEYSTORE_PASS}" \
	-storepass "${KEYSTORE_PASS}" \
	-dname "CN=*.starburstdata.com" \
	-ext san=dns:trino.minitrino.starburstdata.com,dns:trino,dns:localhost

echo "Change truststore password..."
keytool -storepasswd \
        -storepass "${TRUSTSTORE_DEFAULT_PASS}" \
        -new "${TRUSTSTORE_PASS}" \
        -keystore "${TRUSTSTORE_PATH}"

echo "Adding keystore and truststore in ${SSL_DIR}..."
keytool -export \
	-alias trino \
	-keystore "${SSL_DIR}"/keystore.jks \
	-rfc \
	-file "${SSL_DIR}"/trino_certificate.cer \
	-storepass "${KEYSTORE_PASS}" \
	-noprompt

keytool -import -v \
	-trustcacerts \
	-alias trino_trust \
	-file "${SSL_DIR}"/trino_certificate.cer \
	-keystore "${SSL_DIR}"/truststore.jks \
	-storepass "${TRUSTSTORE_PASS}" \
	-noprompt
