# Visualizer

class Visualizer < Processing::App

# Load minim and import the packages we'll be using
load_library "minim"
import "ddf.minim"
import "ddf.minim.analysis"

def setup
    smooth  # smoother == prettier
    size(900,600, P3D)  # 3D render
    background 10  # ...and a darker background color

    setup_sound
  end
  
  def draw
  	update_sound
  	animate_sound
  end

  def setup_sound
  	@minim = Minim.new(self) #creates minim obj for fft
  	@input = @minim.get_line_in
    @input = @minim.loadFile("Born Limitless.mp3", 1024)
    @input.play


    @fft = FFT.new(@input.left.size, 44100)

    @beat=BeatDetect.new

    @freqs = [60, 170, 310, 600, 1000, 3000, 6000, 12000, 14000, 16000]

    @current_ffts = Array.new(@freqs.size, 0.001)
    @previous_ffts = Array.new(@freqs.size, 0.001)
    @max_ffts = Array.new(@freqs.size, 0.001)
    @scaled_ffts = Array.new(@freqs.size, 0.001)

    @fft_smoothing = 0.5
  end

  def update_sound
  	@fft.forward(@input.left)

    @previous_ffts = @current_ffts

    # Iterate over the frequencies of interest and get FFT values
    @freqs.each_with_index do |freq, i|
      # The FFT value for this frequency
      new_fft = @fft.get_freq(freq)

      # Set it as the frequncy max if it's larger than the previous max

      @max_ffts[i] = new_fft if new_fft > @max_ffts[i]

      # Use our "smoothness" factor and the previous FFT to set a current FFT value 
      @current_ffts[i] = ((1 - @fft_smoothing) * new_fft) + (@fft_smoothing * @previous_ffts[i])

      # Set a scaled/normalized FFT value that will be 

      #   easier to work with for this frequency
      @scaled_ffts[i] = (@current_ffts[i]/@max_ffts[i])
    end

    # Check if there's a beat, will be stored in @beat.is_onset
    @beat.detect(@input.left)
  end
  
  def animate_sound
  	# Create a circle animated with sound:
    # Horizontal position will be controlled by the FFT of 60hz (normalized against width)

    # Vertical position - 170hz (normalized against height)
    # red, green, blue - 310hz, 600hz, 1khz (normalized against 255)
    # Size - 170hz (normalized against height), quadrupled on beat

    @size = @scaled_ffts[1]*height/4
    @size *= 3 if @beat.is_onset

    noStroke()

    @x1  = @scaled_ffts[0]*width + width/2
    @y1  = @scaled_ffts[1]*height + height/2

    fill 0, 204, 204

    translate(@x1,@y1)

    sphere(@size)


    # @x1  = @scaled_ffts[0]*width + width/2
    # @y1  = @scaled_ffts[1]*height + height/2

    # @red1    = @scaled_ffts[2]*255
    # @green1  = @scaled_ffts[3]*255
    # @blue1   = @scaled_ffts[4]*255

    # #fill @red1, @green1, @blue1
    # fill 0, 204, 204
    # stroke @red1+20, @green1+20, @blue1+20

    # #ellipse(@x1, @y1, @size, @size)
    # ellipse(@x1, height/2, @size, @size)

    # @x2  = width/2 - @scaled_ffts[0]*width
    # @y2  = @scaled_ffts[1]*height + height/2

    # @red1    = @scaled_ffts[2]*255
    # @green1  = @scaled_ffts[3]*255
    # @blue1   = @scaled_ffts[4]*255

    # #fill @red1, @green1, @blue1
    # fill 0, 204, 204
    # stroke @red1+20, @green1+20, @blue1+20

    # #ellipse(@x1, @y1, @size, @size)
    # ellipse(@x2, height/2, @size, @size)

    # @x3  = width/2 - @scaled_ffts[5]*width
    # @y3  = height/2 - @scaled_ffts[6]*height

    # @red2    = @scaled_ffts[7]*255
    # @green2  = @scaled_ffts[8]*255

    # @blue2   = @scaled_ffts[9]*255

    # #fill @red2, @green2, @blue2
    # fill 0, 204, 0

    # stroke @red2+20, @green2+20, @blue2+20
    # ellipse(width/2, @y3, @size, @size)

    # @x4  = width/2 - @scaled_ffts[5]*width
    # @y4  = @scaled_ffts[6]*height + height/2

    # @red2    = @scaled_ffts[7]*255
    # @green2  = @scaled_ffts[8]*255

    # @blue2   = @scaled_ffts[9]*255

    # #fill @red2, @green2, @blue2
    # fill 0, 204, 0

    # stroke @red2+20, @green2+20, @blue2+20
    # ellipse(width/2, @y4, @size, @size)

  end

end

Visualizer.new :title => "Visualizer"