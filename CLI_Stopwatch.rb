require 'io/console'

class Stopwatch
  def initialize
    @accumulated_time = 0.0
    @start_time = nil
    @running = false
    @laps = []
  end

  def start_or_pause
    if @running
      # Pause the stopwatch
      @accumulated_time += current_Time - @start_time
      @start_time = nil
      @running = false
    else
      # Start the stopwatch
      @start_time = current_Time
      @running = true
    end
  end

  def reset
    @accumulated_time = 0.0
    @start_time = @running ? current_Time : nil
    @laps.clear
    clear_screen
    print_instructions
  end

  def lap
    return unless @running || @accumulated_time > 0
    @laps << elapsed_time
    puts "\rLap #{@laps.length}: #{format_time(@laps.last)}          "
  end

  def elapsed_time
    if @running
      @accumulated_time + (current_Time - @start_time)
    else
      @accumulated_time
    end
  end

  def format_time(seconds)
    mins = (seconds / 60).to_i
    secs = (seconds % 60).to_i
    millis = ((seconds - seconds.to_i) * 100).to_i
    format("%02d:%02d.%02d", mins, secs, millis)
  end

  def run
    clear_screen
    print_instructions

    # Thread to listen for keyboard input without blocking the timer display
    input_thread = Thread.new do
      loop do
        char = STDIN.getch.downcase
        case char
        when 's', ' ' # Spacebar or 'S'
          start_or_pause
        when 'l'
          lap
        when 'r'
          reset
        when 'q', "\u0003" # 'Q' or Ctrl+C
          puts "\nExiting..."
          exit
        end
      end
    end

    # Main loop to update the display
    begin
      loop do
        status = @running ? "[RUNNING]" : "[PAUSED] "
        print "\r#{status} #{format_time(elapsed_time)} "
        sleep(0.05) # Update 20 times a second
      end
    ensure
      input_thread.kill
    end
  end

  private

  # Monotonic clock is strictly for measuring elapsed time accurately
  def current_Time
    Process.clock_gettime(Process::CLOCK_MONOTONIC)
  end

  def clear_screen
    Gem.win_platform? ? system("cls") : system("clear")
  end

  def print_instructions
    puts "=== Deboot STOPWATCH ==="
    puts "Controls: [S/Space] Start/Pause | [L] Lap | [R] Reset | [Q] Quit"
    puts "--------------------------"
  end
end

Stopwatch.new.run

