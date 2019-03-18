# Event sourcing on ruby

Simple repository for playing with event sourcing conceptions from f#

## Sync version

Simple event sourcing system with getting event by hands. It's mean that you need to call event store `get` method every time for getting list of all events. After that you can use projections for calculate state of the system based on events which you get from event store.

Including:
* Events
* Event Store
* Projections for calculating state for list of events

### How it works

```
Event --(append)--> Event store
Event Store --(get)--> list of events

(Projection function (object), base state, list of events) ----> new state
```

### How to run

```
$ bundle exec ruby sync/base.rb
```

## Sync complicated version

Including:
* Events
* Event Store
* Projections for calculating state for list of events
* Producers for call bussines logic
* Aggregators for streams (based on uuid)

## Async version

Including:
* Events
* Event Store
* Projections for calculating state for list of events
* Producers for call bussines logic
* Aggregators for streams (based on uuid)
* Subscribers

### How it works

```
Producers(current events, payload) ----> New Events --(append)--> Event store
Event --(append)--> Event store
Event Store --(get)--> list of events

(Projection function (object), base state, list of events) ----> new state
```

### How to run

```
$ bundle exec ruby async/base.rb
```

