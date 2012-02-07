#!/bin/bash

for ruby in ree 1.8.7 1.9.2 1.9.3; do
    rvm --create $ruby@omniconf
    echo "Running specs with $(rvm current)..."
    bundle check || bundle
    rake spec || exit 1
done

