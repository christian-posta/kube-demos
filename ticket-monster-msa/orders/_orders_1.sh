#!/bin/bash

. $(dirname ${BASH_SOURCE})/../../util.sh

until $(curl --output /dev/null --silent --head --fail http://localhost:8080/node); do
    sleep 5
done

#curl -v -X POST -H "Accept: application/json" -H "Content-Type: application/json" -d '{"ticketRequests":[{"ticketPriceGuideId":1,"quantity":1}],"email":"foo@bar.com","performance":1,"performanceName":"Rock concert of the decade at Roy Thomson Hall"}'  http://localhost:8080/orders/bookings

desc "Add a booking"
run "curl -s -X POST -H \"Accept: application/json\" -H \"Content-Type: application/json\" -d '{\"ticketRequests\":[{\"ticketPriceGuideId\":1,\"quantity\":1}],\"email\":\"foo@bar.com\",\"performance\":1,\"performanceName\":\"Rock concert of the decade at Roy Thomson Hall\"}'  http://localhost:8080/orders/bookings | pretty-json"

