#!/bin/bash

kubectl delete deploy/echo
kubectl delete deploy/logic

kubectl delete svc/echo
kubectl delete svc/logic