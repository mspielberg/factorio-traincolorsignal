local function on_init()
  global.combinator_for_train_id = {}
end

local function station_carriage(station)
  local station_position = station.position
  local position
  local direction = station.direction
  if direction == defines.direction.north then
    position = { x = station_position.x - 2, y = station_position.y + 3 }
  elseif direction == defines.direction.east then
    position = { x = station_position.x - 3, y = station_position.y - 2 }
  elseif direction == defines.direction.south then
    position = { x = station_position.x + 2, y = station_position.y - 3 }
  elseif direction == defines.direction.west then
    position = { x = station_position.x + 3, y = station_position.y + 2 }
  else
    return nil
  end
  return station.surface.find_entities_filtered{
    type = {"locomotive", "cargo-wagon", "fluid-wagon"},
    position = position,
  }[1]
end

local function find_train_color(train)
  local station = train.station
  if not station then return end
  local first_carriage = train.carriages[1]
  local last_carriage = train.carriages[#train.carriages]

  -- find closest carriage
  local carriage = station_carriage(station)

  -- see if train is forward facing or backward facing and set up iteration
  local first, last, step
  if carriage == first_carriage then
    first, last, step = 1, #train.carriages, 1
  elseif carriage == last_carriage then
    first, last, step = #train.carriages, 1, -1
  else
    return nil
  end

  for i = first, last, step do
    local color = train.carriages[i].color
    if color then
      return color
    end
  end

  return nil
end

local function create_combinator(train)
  local station = train.station
  if not station or not station.valid then return end
  local control_behavior = station.get_control_behavior()
  if not control_behavior or not control_behavior.read_stopped_train then return end
  local connected_entities = station.circuit_connected_entities
  if not next(connected_entities.red) and not next(connected_entities.green) then return end

  local color = find_train_color(train)
  if not color then return end

  local combinator = station.surface.create_entity{
    name = "traincolorsignal-combinator",
    position = station.position,
    direction = station.direction,
    force = station.force,
  }

  global.combinator_for_train_id[train.id] = combinator

  combinator.get_control_behavior().parameters = {
    parameters = {
      { index = 1, count = color.r * 255, signal = {type = "virtual", name="signal-red"} },
      { index = 2, count = color.g * 255, signal = {type = "virtual", name="signal-green"} },
      { index = 3, count = color.b * 255, signal = {type = "virtual", name="signal-blue"} },
    }
  }

  combinator.connect_neighbour{
    target_entity = station,
    wire = defines.wire_type.green,
  }
  combinator.connect_neighbour{
    target_entity = station,
    wire = defines.wire_type.red,
  }
end

local function destroy_combinator(train)
  local combinator = global.combinator_for_train_id[train.id]
  global.combinator_for_train_id[train.id] = nil
  if combinator and combinator.valid then
    combinator.destroy()
  end
end

local function on_train_changed_state(event)
  local train = event.train
  if train.state == defines.train_state.wait_station then
    create_combinator(train)
  else
    destroy_combinator(train)
  end
end

local function on_mined_entity(event)
  local entity = event.entity
  if entity.valid and entity.train then
    destroy_combinator(entity.train)
  end
end

script.on_init(on_init)
script.on_event(defines.events.on_train_changed_state, on_train_changed_state)
script.on_event({defines.events.on_player_mined_entity, defines.events.on_entity_died}, on_mined_entity)