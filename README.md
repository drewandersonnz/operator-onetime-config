# operator-onetime-config
A simple operator to apply a configuration once regardless of if it changes.

## Problem:

Operators are designed to protect against configuration drift (intentional or accidental).

Having an operator set a configuration means you could not change this in the future, or you are limited to the supported functionality of the Operator.

In the case of a managed service, how do we enable customers to customise the configuration while ensuring the configuration is applied at-least-once.

## Concept:

```
if exists onetime-store
    return

if exists target-object
    return

apply target-object

apply onetime-store
```

