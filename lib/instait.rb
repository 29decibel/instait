require "instait/version"
require "securerandom"

module Instait
  # Your code goes here...
  class InstaPic
    def initialize(image_file)
      @file = image_file
      @image_info = `identify #{image_file}`
      # make tmp file
      @width = @image_info.match(/(\d*)x(\d*)/)[1].to_i
      @height = @image_info.match(/(\d*)x(\d*)/)[2].to_i
    end

    def colortone(input,color,level,type=0)
      args0 = level
      args1 = 100 - level
      negate = (type == 0 ? '-negate': '')
      command = "convert 
      #{input} 
      ( -clone 0 -fill '#{color}' -colorize 100% ) 
      ( -clone 0 -colorspace gray #{negate} ) 
      -compose blend -define compose:args=#{args0},#{args1} -composite 
      #{input}"
      exec command
    end
    
    def border(input, color = 'black', width = 20)
      exec "convert #{input} -bordercolor #{color} -border #{width}x#{width} #{input}"
    end
    
    def frame(input,frame_name)
      #exec "convert #{input} ( #{frame_name} -resize #{@width}x#{@height}! -unsharp 1.5x1.0+1.5+0.02 ) -flatten #{input}"
    end

    def vignette(input, color_1 = 'none', color_2 = 'black', crop_factor = 1.5)
      crop_x = (@width * crop_factor).floor
      crop_y = (@height * crop_factor).floor
      command = "convert 
      #{input} 
      ( -size #{crop_x}x#{crop_y} 
      radial-gradient:#{color_1}-#{color_2} 
      -gravity center -crop #{@width}x#{@height}+0+0 +repage ) 
      -compose multiply -flatten 
      #{input}"
      exec command
    end

    # ------------------------ filters ---------------------------
    def gotham
      log 'apply gotham'
      make_tmp unless @tmp
      exec "convert #{@tmp} -modulate 120,10,100 -fill '#222b6d' -colorize 20 -gamma 0.5 -contrast -contrast #{@tmp}"
      #`convert #{@tmp} -modulate 120,10,100 -fill '#222b6d' -colorize 20 -gamma 0.5 -contrast -contrast #{@tmp}"`
    end

    def lomo(border=false)
      log 'apply lomo'
      make_tmp unless @tmp
      `convert #{@tmp} -channel R -level 33% -channel G -level 33% #{@tmp}`
       vignette(@tmp)
       border(@tmp,'white') if border
    end

    # TOASTER
    def toaster
      log "apply toaster"
      make_tmp unless @tmp
      colortone(@tmp, '#330000', 100, 0)
      exec "convert #{@tmp} -modulate 150,80,100 -gamma 1.2 -contrast -contrast #{@tmp}"
      vignette(@tmp, 'none', 'LavenderBlush3')
      vignette(@tmp, '#ff9966', 'none')
      log "end"
    end

    def nashville
      log "apply nashville"
      make_tmp unless @tmp
      colortone(@tmp, '#222b6d', 100, 0)
      colortone(@tmp, '#f7daae', 100, 1)
      
      `convert #{@tmp} -contrast -modulate 100,150,100 -auto-gamma #{@tmp}`
    end

    # KELVIN
    def kelvin
      log 'apply kelvin'
      make_tmp unless @tmp
      command = "convert 
        ( #{@tmp} -auto-gamma -modulate 120,50,100 ) 
        ( -size #{@width}x#{@height} -fill rgba(255,153,0,0.5) -draw 'rectangle 0,0 #{@width},#{@height}' ) 
        -compose multiply 
        #{@tmp}"
      exec command
      #frame(@tmp, __method__);
    end

    # TILT SHIFT
    def tilt_shift
      log 'apply tilt_shift'
      make_tmp unless @tmp
      command = "convert 
      ( #{@tmp} -gamma 0.75 -modulate 100,130 -contrast ) 
      ( +clone -sparse-color Barycentric '0,0 black 0,%h white' -function polynomial 4,-4,1 -level 0,50% ) 
      -compose blur -set option:compose:args 5 -composite 
      #{@tmp}"
      exec command
    end

    def make_tmp(file_name=nil)
      @tmp = (file_name||SecureRandom.hex(5)) + File.extname(@file)
      `cp #{@file} #{@tmp}`
    end

    def exec(command_str)
      # escape new line
      command_str.gsub!('\n','\\')
      # strip multiple chars
      command_str.gsub!(/\s+/,' ')
      # replace (
      command_str.gsub!(/\(/,'\\(')
      # replace )
      command_str.gsub!(/\)/,'\\)')
      `#{command_str}`
    end

    def log(msg)
      puts "********************#{msg}*********************"
    end

    def apply_all
      make_tmp('kelvin')
      kelvin

      make_tmp('lomo')
      lomo(true)

      make_tmp('tilt_shift')
      tilt_shift

      make_tmp('gotham')
      gotham

      make_tmp('nashville')
      nashville

      make_tmp('toaster')
      toaster
    end
    
  end
end

