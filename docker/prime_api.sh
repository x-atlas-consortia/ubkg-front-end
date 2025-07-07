#!/bin/bash
set -e
set -u

#########
# neo4j INITIALIZATION SCRIPT
# When a Cypher query is executed for the first time in a new neo4j instance, neo4j
# must add the query plan to its plan cache. Plan caching results in the initial
# execution of the query taking longer than subsequent executions.
# In the ubkg-api in UBKGBox, the initial execution fails with a HTTP 500 error.
# A workaround is to execute a set of known queries immediately after the neo4j
# instance is up, similar to priming a pump. In particular, this mitigates the risk
# of the Guesdt application failing in the initial load of its index.html page, because
# that page populates with content from the ubkg-api.
##########

# Wait in lieu of depending on the healthcheck for ubkg-back-end in Docker.
# 30 seconds appears to be sufficient time for the neo4j instance to be ready.
sleep 30

echo "UBKG-api initialization script"

UBKG_URL=http://ubkg-api:8080

# Guesdt specific
echo "calling: /codes/FMA:7149/codes"
curl --request GET \
 --url "${UBKG_URL}/codes/FMA:7149/codes" \
 --header "Accept: application/json" | cut -c1-60

echo "calling: /codes/FMA:7149/concepts"
curl --request GET \
 --url "${UBKG_URL}/codes/FMA:7149/concepts" \
 --header "Accept: application/json" | cut -c1-60

echo "calling: /codes/FMA:7149/terms"
curl --request GET \
 --url "${UBKG_URL}/codes/FMA:7149/terms" \
 --header "Accept: application/json" | cut -c1-60

echo "calling: /concepts/C0460002/concepts"
curl --request GET \
 --url "${UBKG_URL}/concepts/C0460002/concepts" \
 --header "Accept: application/json" | cut -c1-60

# Other
echo "calling: /concepts/C0460002/codes"
curl --request GET \
 --url "${UBKG_URL}/concepts/C0460002/codes" \
 --header "Accept: application/json" | cut -c1-60

echo "calling: /concepts/C0460002/definitions"
curl --request GET \
 --url "${UBKG_URL}/concepts/C0460002/definitions" \
 --header "Accept: application/json" | cut -c1-60
echo
echo

echo "calling: /concepts/C0460002/nodeobjects"
curl --request GET \
 --url "${UBKG_URL}/concepts/C0460002/nodeobjects" \
 --header "Accept: application/json" | cut -c1-60

echo "Initialization complete"
echo "UBKGBox is ready"

