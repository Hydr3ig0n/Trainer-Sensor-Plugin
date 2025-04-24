if true # << Make true to use this script, false to disable.
    #===============================================================================
    #
    #  Trainer Sensor Script
    #  Original Author     : Drimer
    #  Updated to v21.1 by Hydr3ig0n
    #
    #===============================================================================
    
    #===============================================================================
    #                             **  Settings here! **
    #
    # RANGE sets the... range of detection! If it is set to 0 it will take the
    # value x from 'Trainer(x)' (Event's name!)
    #
    # BAR_OPACITY is used to set the transparency to the focus bars.
    #
    # SELF_SWITCH is used to identify those trainers you already fought against of.
    #
    # BAR_HEIGHT sets the the focus bars' height value.
    #
    # BAR_GRAPHIC allows you to load your own graphic from 'Graphics/Pictures/'
    # if it is set to "" or nil, the system will create them for you. If not, then
    # the BAR_HEIGHT will be ignored as well as the BAR_OPACITY constant.
    #===============================================================================
    module TrainerSensor
      RANGE       = 0
      BAR_OPACITY = 255/2
      SELF_SWITCH = "A"
      BAR_HEIGHT  = Graphics.height/6
      BAR_GRAPHIC = "newBattleMessageBox"
      # If you use EBS, a good option is set this value to "EBS/newBattleMessageBox"
    end
      
    
    #===============================================================================
    # **  
    #===============================================================================
    module TrainerSensor
      @top = Sprite.new
      @top.z = 1
      @bottom = Sprite.new
      @bottom.z = 1
      @triggered = false
      @custom_graphic = false
      @created = false
      
      def self.create
        if ["", nil].include?(BAR_GRAPHIC)
          @top.bitmap = Bitmap.new(Graphics.width, BAR_HEIGHT)
          @top.bitmap.fill_rect(0,0,@top.bitmap.width,@top.bitmap.height,
            Color.new(-255,-255,-255, BAR_OPACITY))
        else
          @top.bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/", BAR_GRAPHIC)
          @top.ox = @top.bitmap.width/2
          @top.x = Graphics.width/2
          @top.y = -@top.bitmap.height
          @top.mirror = true
          @top.angle = 180
          @custom_graphic = true
        end
        @top.oy = @top.bitmap.height
        @bottom.bitmap = @top.bitmap.clone
        if @custom_graphic
          @bottom.ox = @bottom.bitmap.width/2
          @bottom.x = Graphics.width/2
        end
        @bottom.y = Graphics.height
        @created = true
      end
      
      def self.triggered?
        @triggered
      end
      
      def self.show
        self.create if !@created
        @triggered = true
      end
      
      def self.hide
        @triggered = false
      end
      
      def self.update
        return if !@created
        if @triggered
          if @top.y < (@custom_graphic ? 0 : (BAR_HEIGHT - 6) )
            @top.y += 6
            @bottom.y -= 6
          end
        else
          if @top.y > (@custom_graphic ? -@top.bitmap.height : 0 )
            @top.y -= 6
            @bottom.y += 6
          end    
        end
      end
      
      # Function to check if the player is in an event's range
      def self.InRange?(event, distance)
        distance = RANGE > 0 ? RANGE : distance
        return false if distance<=0
        rad = (Math.hypot((event.x - $game_player.x),(event.y - $game_player.y))).abs
        return true if (rad <= distance)
        return false
      end
    end
    
    module Graphics
      class << self
        alias trainer_detection_update update
        def update
          trainer_detection_update
          TrainerSensor.update if $scene && $scene.is_a?(Scene_Map)
        end
      end
    end
    
    
    EventHandlers.add(:on_step_taken, :trainer_sensor,
      proc { |event|
      for event in $game_map.events.values
        if event.name[/^Trainer\((\d+)\)$/] && event.isOff?(TrainerSensor::SELF_SWITCH)
          distance=$~[1].to_i
          if TrainerSensor.InRange?(event, distance)
            TrainerSensor.show()
            break
          else
            TrainerSensor.hide() if TrainerSensor.triggered?
          end
        else
          TrainerSensor.hide() if TrainerSensor.triggered?
        end
      end
    })
    end