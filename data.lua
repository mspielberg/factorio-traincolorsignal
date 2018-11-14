local empty_sprite = {
  filename = "__core__/graphics/empty.png",
  width = 0,
  height = 0,
}
data:extend{
    {
        type = "constant-combinator",
        name = "traincolorsignal-combinator",
        item_slot_count = 3,
        sprites = empty_sprite,
        activity_led_sprites = empty_sprite,
        activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
        circuit_wire_connection_points = circuit_connector_definitions["train-station"].points,
        circuit_wire_max_distance = default_circuit_wire_max_distance,
    }
}