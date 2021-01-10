






-- local walrus_brain = function(self)

-- 	if self.hp <= 0 then	
-- 		mob_core.on_die(self)
-- 		return
-- 	end

-- 	local pos = mobkit.get_stand_pos(self)
-- 	local prty = mobkit.get_queue_priority(self)
-- 	local player = mobkit.get_nearby_player(self)

-- 	mob_core.random_sound(self, 16/self.dtime)

-- 	if mobkit.timer(self,1) then
-- 		mob_core.vitals(self)
-- 		mob_core.growth(self)
-- 		if self.status ~= "following" then
--             if self.attention_span > 1 then
--                 self.attention_span = self.attention_span - 1
--                 mobkit.remember(self, "attention_span", self.attention_span)
--             end
-- 		else
-- 			self.attention_span = self.attention_span + 1
-- 			mobkit.remember(self, "attention_span", self.attention_span)
-- 		end

-- 		if prty < 3
--         and self.breeding then
--             better_fauna.hq_breed(self, 3)
-- 		end
		
--         if prty < 2
--         and player then
--             if self.attention_span < 5 then
--                 if mob_core.follow_holding(self, player) then
--                     better_fauna.hq_follow_player(self, 2, player)
--                     self.attention_span = self.attention_span + 1
--                 end
--             end
--         end

-- 		if mobkit.is_queue_empty_high(self) then
-- 			mob_core.hq_roam(self, 0)
-- 		end
-- 	end
-- end

local walrus_brain = function(self)

    if self.hp <= 0 then    
        mob_core.on_die(self)
        return
    end

    local pos = mobkit.get_stand_pos(self)
    local prty = mobkit.get_queue_priority(self)
    local player = mobkit.get_nearby_player(self)

    mob_core.random_sound(self, 16/self.dtime)

    if mobkit.timer(self,1) then

        mob_core.vitals(self)
        mob_core.growth(self)

        if self.status ~= "following" then
            if self.attention_span > 1 then
                self.attention_span = self.attention_span - 1
                mobkit.remember(self, "attention_span", self.attention_span)
            end
        else
            self.attention_span = self.attention_span + 1
            mobkit.remember(self, "attention_span", self.attention_span)
        end

        -- if prty < 3
        -- and self.breeding
        -- and self.isonground then
        --     better_fauna.hq_breed(self, 3)
        -- end
        
        if prty < 2
        and player then
            if self.attention_span < 5 then
                if mob_core.follow_holding(self, player) then
                    if self.isinliquid then
                        mob_core.hq_follow_holding(self, 2, player)
                    else
                        mob_core.hq_aqua_follow_holding(self, 2, player)
                    end
                    self.attention_span = self.attention_span + 1
                end
            end
        end

        if mobkit.is_queue_empty_high(self) then
            if self.isinliquid then
                mob_core.hq_aqua_roam(self, 0, 3)
            else
                mob_core.hq_roam(self, 0)
            end
        end
    end
end




minetest.register_entity("mobs_walrus:walrus",{

        -- required minetest api props
	max_hp = 45,    
	view_range = 10,					-- nodes/meters
	reach = 2,
	armor = 200,
	damage = 5,
	passive = false,
	armor_groups = {fleshy=200},
    physical = true,
    collide_with_objects = true,
	collisionbox = {-0.525, -0.75, -0.525, 0.525, 0.6, 0.525},
	visual_size = {x=15,y=15},
	scale_stage1 = 0.5,
    scale_stage2 = 0.65,
    scale_stage3 = 0.80,
	visual = "mesh",
    mesh = "mobs_walrus_walrus.b3d",
    textures = {"mobs_walrus_walrus1.png","mobs_walrus_walrus2.png",},
    animation = {
		walk={range={x=55,y=95},speed=15,loop=true},
		run={range={x=55,y=95},speed=20,loop=true},	
		stand={range={x=0,y=50},speed=15,loop=true},
		punch={range={x=100,y=145},speed=15,loop=true},	-- single
	},
	

	obstacle_avoidance_range = 0,
	surface_avoidance_range = 0,
	floor_avoidance_range = 1,


	sounds = {
		alter_child_pitch = true,
		random = {								--variant, sound is chosen randomly
			{
			name = 'walrus_random_1',
			gain=5,
			fade=5,
			pitch=0,
			},
			{
			name = 'walrus_random_2',
			gain=5,
			fade=5,
			pitch=0,
			},
			{
			name = 'walrus_random_3',
			gain=5,
			fade=5,
			pitch=0,
			},
		},
		hurt = {								--variant, sound is chosen randomly
			{
			name = 'walrus_random_1',
			gain=5,
			fade=5,
			pitch=0,
			},
			{
			name = 'walrus_random_2',
			gain=5,
			fade=5,
			pitch=0,
			},
			{
			name = 'walrus_random_3',
			gain=5,
			fade=5,
			pitch=0,
			},
		},
		war_cry = 'walrus_war_cry',
		attack = {								--variant, sound is chosen randomly
			{
			name = 'walrus_attack_1',
			gain=5,
			fade=5,
			pitch=0,
			},
			{
			name = 'walrus_attack_2',
			gain=5,
			fade=5,
			pitch=0,
			},

		},
	},
	max_speed = 1,					-- m/s
    stepheight = 1.1,
    jump_height = 1.1,				-- nodes/meters
    buoyancy = .5,			-- (0,1) - portion of collisionbox submerged
                            -- = 1 - controlled buoyancy (fish, submarine)
                            -- > 1 - drowns
                            -- < 0 - MC like water trampolining
	lung_capacity = 500, 		-- seconds
    timeout = 1200,			-- entities are removed after this many seconds inactive
                            -- 0 is never
                            -- mobs having memory entries are not affected
	ignore_liquidflag = true,			-- range is distance between attacker's collision box center
	semiaquatic = true,
	core_growth = false,
	push_on_collide = true,
	catch_with_net = true,





	follow = {
		"water_life:riverfish",
		"water_life:piranha",
		"water_life:coralfish",
		"water_life:clownfish",
		"water_life:urchin_item",
	},
    drops = {
		{name = "water_life:meat_raw", chance = 1, min = 2, max = 5},
    },
    on_step = better_fauna.on_step,
    on_activate = better_fauna.on_activate,		
    get_staticdata = mobkit.statfunc,
	logic = walrus_brain,
	on_rightclick = function(self, clicker)
		if mob_core.feed_tame(self, clicker, 5, true, false) then return end
		mob_core.protect(self, clicker, false)
		mob_core.nametag(self, clicker, true)
		mob_core.capture_mob(self, clicker, "better_fauna:net", 3, 1, false)
		mob_core.capture_mob(self, clicker, "water_life:lasso", 3, 1, false)
	end,
	on_punch = function(self, puncher, _, tool_capabilities, dir)
		mobkit.clear_queue_high(self)
		--apply damage
		mob_core.on_punch_basic(self, puncher, tool_capabilities, dir)
		--if hurt, flee
		if self.hp < 5 then

			-- mob_core.on_punch_runaway(self, puncher, true , false)
			if self.isinliquid then
				mob_core.hq_swimfrom(self,10,puncher,3)
			else
				mobkit.hq_runfrom(self,10,puncher)
			end
			if math.random(1,3) == 1 then
				mob_core.make_sound(self, 'random')
			end
			

			local pos = self.object:get_pos()
			local objs = minetest.get_objects_inside_radius(pos, self.view_range)
			for n = 1, #objs do
				local luaent = objs[n]:get_luaentity()
				if luaent and luaent.name == self.name and luaent.owner == self.owner and mobkit.is_alive(luaent) then
					if luaent.hp < 5 then
						if luaent.isinliquid then
							mob_core.hq_swimfrom(luaent,10,puncher,3)
						else
							mobkit.hq_runfrom(luaent,10,puncher)
						end
						if math.random(1,3) == 1 then
							mob_core.make_sound(luaent, 'random')
						end
					end
				end
			end
			
		else
			--attack
			-- mob_core.on_punch_retaliate(self, puncher, true, false)
			

			local pos = self.object:get_pos()
			local objs = minetest.get_objects_inside_radius(pos, self.view_range)
			if self.isinliquid then
				mob_core.hq_aqua_attack(self, 10, puncher, 3)
			else
				mob_core.hq_hunt(self, 10, puncher)
			end
			if math.random(1,3) == 1 then
				mob_core.make_sound(self, 'war_cry')
			else
				mob_core.make_sound(self, 'attack')
			
			end
			
			for n = 1, #objs do
				
				local luaent = objs[n]:get_luaentity()
				if luaent and luaent.name == self.name and luaent.owner == self.owner and mobkit.is_alive(luaent) then
					if luaent.hp > 5 then
						if luaent.isinliquid then
							mob_core.hq_aqua_attack(luaent, 10, puncher, 3)
						else
							mob_core.hq_hunt(luaent, 10, puncher)
						end
						if math.random(1,3) == 1 then
							mob_core.make_sound(luaent, 'war_cry')
						else
							mob_core.make_sound(luaent, 'attack')
						
						end
					end
					
				end
			end
			if math.random(1,3) == 1 then
				mob_core.make_sound(self, 'war_cry')
			else
				mob_core.make_sound(self, 'attack')
			
			end
		end
	end,


    
	attack={range=2,damage_groups={fleshy=7}},	
    damage_groups={{fleshy=5}},	-- and the tip of the murder weapon in nodes/meters
	armor_groups = {fleshy=200},



})


mob_core.register_spawn_egg("mobs_walrus:walrus", "171c18" ,"611d04")
mob_core.register_set("mobs_walrus:walrus", "mobs_walrus_walrus1.png", true)
mob_core.register_spawn({
	name = "mobs_walrus:walrus",
	nodes = {"default:snow", "default:ice"},
	min_light = 0,
	max_light = 20,
	min_height = -31000,
	max_height = 31000,
	group = 10,
	optional = {
		biomes = {
			"snowy_grassland",
			"deciduous_forest",
			"icesheet_ocean",
			"tundra_highland",
			"taiga",
			"tundra",
			"icesheet",
			"taiga_beach",
			"tundra_beach",
			"tundra_ocean",
		}
	}
}, 10, 100)


mob_core.register_spawn({
	name = "mobs_walrus:walrus",
	nodes = {"default:snow", "default:ice"},
	min_light = 0,
	max_light = 20,
	min_height = -31000,
	max_height = 31000,
	group = 8,
	optional = {
		biomes = {
			"snowy_grassland",
			"deciduous_forest",
			"taiga",
			"tundra",
			"icesheet",
			"taiga_beach"
		}
	}
}, 16, 1)


if minetest.get_modpath("water_life") then
	water_life.register_shark_food("mobs_walrus:walrus")
end