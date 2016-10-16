#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

desc "Let local service bootstrap"
read -s

desc "Add a booking"
run "curl -s -v -X POST -H \"Accept: application/json\" -H \"Content-Type: application/json\" -d '{\"ticketRequests\":[{\"ticketPriceGuideId\":1,\"quantity\":1}],\"email\":\"foo@bar.com\",\"performance\":1,\"performanceName\":\"Rock concert of the decade at Roy Thomson Hall\"}'  http://localhost:8080/orders/bookings | pretty-json"

