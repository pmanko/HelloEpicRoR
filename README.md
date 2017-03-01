# SMART on FHIR

## Overview

1. No client existed, so implemented communication from the basics

2. After hitting a couple of roadblocks due to not being comfortable in php/cake 
    * Switched over to ruby on rails to get things moving w/o wasting time on framework
    * Have not pulled everything back yet

3. Authorization flow:
- authorized with the client secret
- after "handshake", token is all you need
- when launched from an app --> has a launch context Id which gets passed to authorization path --> context
- Without context, same type of authorization, but scope needs to be specified


## Possible Directions
1. Integrate login with local users
2. Use FHIR client when parsing resources
    - https://packagist.org/packages/dcarbone/php-fhir
    - https://github.com/fhir-crucible/fhir_client
3. Integrate with mPOWEr OR mPOWEr API

## Open Questions
1. How do we launch in context of providers?

## Epic Trip

1. Shortest route for feasability 

## Difference between sandboxes:
1. SOF sandbox
2. Epic Sandbox
3. 