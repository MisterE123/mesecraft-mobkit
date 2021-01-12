



local bat_brain = function(self)

    if self.hp <= 0 then    
        mob_core.on_die(self)
        return
    end

    local pos = mobkit.get_stand_pos(self)
    local prty = mobkit.get_queue_priority(self)
    local player = mobkit.get_nearby_player(self)



    if mobkit.timer(self,60) then
        if pos.y > 0 and not (minetest.find_node_near(pos, 10, {'group:leaves'}) or minetest.find_node_near(pos, 10, {'group:crumbly'}) or minetest.find_node_near(pos, 10, {'group:stone'}) or minetest.find_node_near(pos, 10, {'default:water_source'})) then
            self.soar_height = self.soar_height - math.random(5,10)
        elseif pos.y > 0 and (minetest.find_node_near(pos, 5, {'group:leaves'}) or minetest.find_node_near(pos, 5, {'group:crumbly'}) or minetest.find_node_near(pos, 5, {'group:stone'}) or minetest.find_node_near(pos, 5, {'default:water_source'})) then
            self.soar_height = self.soar_height + math.random(5,20)
        end
    end
    
    if mobkit.timer(self,10) then

        if pos.y < 0 then
            self.soar_height = self.soar_height + math.random(-3,5)
        end
        --put cave nav here
    end
    local tod = minetest.get_timeofday()
    if tod < .2 or tod >.7 or pos.y < 0 then
        mob_core.random_sound(self, 16/self.dtime)
    end
    
       

    if mobkit.timer(self,1) then

        mob_core.vitals(self)
        mob_core.growth(self)

        --poop every so often

        if math.random(1, 100) == 1 then
            local pos = self.object:get_pos()

            minetest.add_item(pos, "mobs_creatures:poop_turd")
    
            minetest.sound_play("mobs_creatures_common_poop", {
                    pos = pos,
                    gain = 1.0,
                    max_hear_distance = 8,
            })  
        end

        

        if mobkit.is_queue_empty_high(self) then
            local tod = minetest.get_timeofday()
            if tod > .2 and tod <.7 and pos.y > 0 then
                -- go to sleep

                local nearleaves = minetest.find_node_near(pos,1,'group:leaves')
                if not nearleaves then
                    if minetest.get_node_light(pos) > 10 and math.random(1,5) == 1 and pos.y > 0 then
                        self.hp = 0
                    end
                    local leaves = mob_core.find_node_expanding(self, 'group:leaves')
                    if leaves then
                        mob_core.fly_to_next_waypoint(self, leaves, 1)
                    else
                        mob_core.hq_aerial_roam(self, 0, 1.5)
                    end
                else
                    self.object:set_pos(nearleaves)
                    mobkit.clear_queue_high(self)
                    mobkit.clear_queue_low(self)
                    mobkit.lq_idle(self, 20, "stand")
                end
            else
                mob_core.hq_aerial_roam(self, 0, 1)
            end
        end
    end
end




minetest.register_entity("mobs_creatures:bat",{

        -- required minetest api props
	max_hp = 6,    
    view_range = 40,					-- nodes/meters
    soar_height = 25,
	reach = 2,
	armor = 200,
	damage = 2,
	passive = false,
	armor_groups = {fleshy=200},
    physical = true,
    collide_with_objects = true,
	collisionbox = {-0.25, -0.01, -0.25, 0.25, 0.89, 0.25},
	visual_size = {x=1,y=1},
	scale_stage1 = 0.5,
    scale_stage2 = 0.65,
    scale_stage3 = 0.80,
	visual = "mesh",
    mesh = "mobs_creatures_bat.b3d",
	textures = {"mobs_creatures_bat.png"},
    animation = {
		walk={range={x=0,y=40},speed=80,loop=true},
		run={range={x=0,y=40},speed=80,loop=true},	
		stand={range={x=0,y=40},speed=80,loop=true},
        punch={range={x=0,y=40},speed=80,loop=true},
        fly={range={x=0,y=40},speed=80,loop=true},	-- single
        land={range={x=0,y=40},speed=80,loop=true},
        fast={range={x=0,y=40},speed=80,loop=true},
        swim={range={x=0,y=40},speed=80,loop=true},
        
	},
	

	obstacle_avoidance_range = 1,
	surface_avoidance_range = 1,
	floor_avoidance_range = 1,


	sounds = {
		alter_child_pitch = true,
        random = "mobs_creatures_bat_random", 
		hurt = "mobs_creatures_bat_damage",
		war_cry = 'mobs_creatures_bat_attack',
        attack = "mobs_creatures_bat_attack",
        die = "mobs_creatures_bat_death",
        jump = "mobs_creatures_bat_jump",
		
	},
	max_speed = 10,					-- m/s
    stepheight = 1.1,
    jump_height = 1.1,				-- nodes/meters
    buoyancy = .5,			-- (0,1) - portion of collisionbox submerged
                            -- = 1 - controlled buoyancy (fish, submarine)
                            -- > 1 - drowns
                            -- < 0 - MC like water trampolining
	lung_capacity = 500, 		-- seconds
    timeout = 120,			-- entities are removed after this many seconds inactive
                            -- 0 is never
                            -- mobs having memory entries are not affected
	ignore_liquidflag = false,			-- range is distance between attacker's collision box center
	semiaquatic = false,
	core_growth = false,
	push_on_collide = true,
	catch_with_net = true,


    drops = {
		--{name = "water_life:meat_raw", chance = 1, min = 2, max = 5},
    },
    on_step = better_fauna.on_step,
    on_activate = better_fauna.on_activate,		
    get_staticdata = mobkit.statfunc,
	logic = bat_brain,
	on_rightclick = function(self, clicker)
		mob_core.capture_mob(self, clicker, "better_fauna:net", 3, 1, true)
	end,
	on_punch = function(self, puncher, _, tool_capabilities, dir)
		mobkit.clear_queue_high(self)
		--apply damage
		mob_core.on_punch_basic(self, puncher, tool_capabilities, dir)
		--if hurt, flee
		if self.hp < 2 then

			-- mob_core.on_punch_runaway(self, puncher, true , false)
		
			mobkit.hq_runfrom(self,10,puncher)
			
			if math.random(1,3) == 1 then
				mob_core.make_sound(self, 'random')
			end
			

			
		else
			--attack
			-- mob_core.on_punch_retaliate(self, puncher, true, false)
			

			local pos = self.object:get_pos()
            mob_core.hq_hunt(self, 10, puncher)
        
			if math.random(1,3) == 1 then
				mob_core.make_sound(self, 'war_cry')
			else
				mob_core.make_sound(self, 'attack')
			
			end
			
			if math.random(1,3) == 1 then
				mob_core.make_sound(self, 'war_cry')
			else
				mob_core.make_sound(self, 'attack')
			
			end
		end
	end,


    
	attack={range=1,damage_groups={fleshy=1}},	
    damage_groups={{fleshy=1}},	-- and the tip of the murder weapon in nodes/meters
	armor_groups = {fleshy=200},



})


mob_core.register_spawn_egg("mobs_creatures:bat", "a1443d" ,"611d04")
mob_core.register_set("mobs_creatures:bat", "mobs_creatures_bat.png", true)
mob_core.register_spawn({
	name = "mobs_creatures:bat",
	nodes = {"group:leaves"},
	min_light = 0,
	max_light = 10,
	min_height = -31000,
	max_height = 31000,
	group = 1,
	optional = {
		--biomes = {
			--"snowy_grassland",
			--"deciduous_forest",
			--"icesheet_ocean",
			--"tundra_highland",
			--"taiga",
			--"tundra",
			--"icesheet",
			--"taiga_beach",
			--"tundra_beach",
			--"tundra_ocean",
		--}
	}
}, 2, 2)

mob_core.register_spawn({
	name = "mobs_creatures:bat",
	nodes = {"group:leaves"},
	min_light = 0,
	max_light = 10,
	min_height = -31000,
	max_height = 31000,
	group = 1,
	optional = {

	}
}, 2, 2)

mob_core.register_spawn({
	name = "mobs_creatures:bat",
	nodes = {"group:stone"},
	min_light = 0,
	max_light = 10,
	min_height = -500,
	max_height = 0,
	group = 15,
	optional = {

	}
}, 2, 2)


-- if minetest.get_modpath("water_life") then
-- 	water_life.register_shark_food("mobs_walrus:walrus")
-- end