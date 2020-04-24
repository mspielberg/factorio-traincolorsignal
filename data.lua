local empty_sprite = {
  filename = "__core__/graphics/empty.png",
  width = 1,
  height = 1,
}
data:extend{
    {
        type = "constant-combinator",
        name = "traincolorsignal-combinator",
        collision_mask = {},
        item_slot_count = 3,
        sprites = empty_sprite,
        activity_led_sprites = empty_sprite,
        activity_led_light_offsets = {{0,0},{0,0},{0,0},{0,0}},
        circuit_wire_connection_points = circuit_connector_definitions["train-station"].points,
        circuit_wire_max_distance = default_circuit_wire_max_distance,
        draw_circuit_wires = false,
    }
}