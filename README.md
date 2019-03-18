# Event sourcing on ruby

Simple repository for playing with event sourcing conceptions from f#

## Sync version

Simple event sourcing system with getting event by hands. It's mean that you need to call event store `get` method every time for getting list of all events. After that you can use projections for calculate state of the system based on events which you get from event store.

Including:
* Events
* Event Store
* Projections for calculating state for list of events

Entry point: `base.rb` file.

### How to run
```
$ bundle exec ruby sync/base.rb
```

