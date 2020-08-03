#!/bin/bash

TEST_NAMESPACE=apply-once
TEST_OBJECT=apply-once-test
TEST_TYPE=configmap

TARGET_NAMESPACE=apply-once
TARGET_OBJECT=apply-once-target
TARGET_TYPE=configmap

exit_on_error() {
    if [ $1 -gt 0 ]; then
        echo "Error:" $2
        exit $1
    fi
}

exit_on_success() {
    if [ $1 -eq 0 ]; then
        echo "Success:" $2
        exit $1
    fi
}

# get TEST_NAMESPACE, fail if not found
oc get namespace ${TEST_NAMESPACE} > /dev/null 2>&1
TEST_NAMESPACE_FOUND=$?
exit_on_error ${TEST_NAMESPACE_FOUND} "TEST_NAMESPACE not found"

# get TEST_OBJECT, if exists stop
oc get ${TEST_TYPE} -n ${TEST_NAMESPACE} ${TEST_OBJECT} > /dev/null 2>&1
TEST_OBJECT_FOUND=$?
exit_on_success ${TEST_OBJECT_FOUND} "TEST_OBJECT found"

# get TARGET_NAMESPACE, fail if not found
oc get namespace ${TARGET_NAMESPACE} > /dev/null 2>&1
TARGET_NAMESPACE_FOUND=$?
exit_on_error ${TARGET_NAMESPACE_FOUND} "TARGET_NAMESPACE not found"

# get TARGET_OBJECT, if exists stop
oc get ${TARGET_TYPE} -n ${TARGET_NAMESPACE} ${TARGET_OBJECT} > /dev/null 2>&1
TARGET_OBJECT_FOUND=$?
if [ ${TARGET_OBJECT_FOUND} -eq 0 ]; then
    if [ ${TEST_OBJECT_FOUND} -ne 0 ]; then
        # apply TEST_OBJECT, to stop future executions
        oc create ${TEST_TYPE} -n ${TEST_NAMESPACE} ${TEST_OBJECT} --from-literal done=true
    fi
fi
exit_on_success ${TARGET_OBJECT_FOUND} "TARGET_OBJECT found"

# apply TARGET_OBJECT once
oc create ${TARGET_TYPE} -n ${TARGET_NAMESPACE} ${TARGET_OBJECT} --from-literal done=true

# wait for time to apply
sleep 2

# get TARGET_OBJECT, error if not exists
oc get ${TARGET_TYPE} -n ${TARGET_NAMESPACE} ${TARGET_OBJECT} > /dev/null 2>&1
TARGET_OBJECT_FOUND=$?
exit_on_error ${TARGET_OBJECT_FOUND} "TARGET_OBJECT not found"

# apply TEST_OBJECT, to stop future executions
oc create ${TEST_TYPE} -n ${TEST_NAMESPACE} ${TEST_OBJECT} --from-literal done=true

# have an output at end so script is never silent
date -u
