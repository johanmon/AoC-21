defmodule Adv do

  def day1a() do
    count = fn (x, {prev, sum})  ->
      if (x > prev) do
	{x, sum+1}
      else
	{x, sum}
      end
    end
    {_, answer} = File.stream!("day1.csv") |>
      Stream.map( fn (r) -> {n, _} = Integer.parse(r); n end) |>
      Enum.reduce({:inf, 0}, count)
    answer
  end

  def day1b() do
    count = fn (x, {p1, p2, p3, sum}) ->
        if add(x, add(p1, p2)) > add(p1, add(p2,p3)) do
          {x,p1,p2, sum+1}
        else
          {x,p1,p2, sum}
        end
    end

   {_,_,_, answer} =  File.stream!("day1.csv") |>
      Stream.map( fn (r) -> {n, _} = Integer.parse(r); n end) |>
      Enum.reduce({:inf, :inf, :inf, 0}, count)
   answer
  end

  defp add(_, :inf) do :inf end
  defp add(:inf, _) do :inf end
  defp add(x, y) do x+y end  

  ##==================================================================

  
  def day2a() do
    count = fn ({dir, val}, {depth, dist}) ->
      case dir do
	"down" ->	
	  {depth+val, dist}
	"up" ->
	  {depth-val, dist}
	"forward" ->
	  {depth, dist+val}
      end
    end
    File.stream!("day2.csv") |>
      Stream.map( fn (r) -> [dir, nr] = String.split(r); {val, _} = Integer.parse(nr); {dir, val} end) |>
      Enum.reduce({0,0}, count)
  end

  
  def day2b() do 
    count = fn ({dir, val}, {depth, dist, aim}) ->
      case dir do
	"down" ->	
	  {depth, dist, aim+val}
	"up" ->
	  {depth, dist, aim-val}
	"forward" ->
	  {depth+(aim*val), dist+val, aim}
      end
    end

    File.stream!("day2.csv") |>
      Stream.map( fn (r) -> [dir, nr] = String.split(r); {val, _} = Integer.parse(nr); {dir, val} end) |>
      Enum.reduce({0,0,0}, count)
  end   

  ##==================================================================

  def day3a() do

    {l, seq} = File.stream!("day3.csv") |>
      Enum.map( &chars_to_bin/1 ) |>
      Enum.reduce({0,[]}, fn(x, {l,s}) -> {l+1, add_bin(x,s)} end)

    gamma = rate(seq, l, &</2) 

    epsilon = rate(seq, l, &>=/2) 
    
    {bin_to_int(gamma), bin_to_int(epsilon)}
  end

  def  rate(ks, l, op) do
    Enum.map(ks, fn x -> if op.(x,(l-x)), do: 0, else: 1  end)
  end

  ## We need this to parse the line as a list of ones and zeros i.e. [1,0,1,1] 

  def chars_to_bin(<<_>>) do [] end
  def chars_to_bin(<<?0, rest::binary>>) do [0| chars_to_bin(rest)] end
  def chars_to_bin(<<?1, rest::binary>>) do [1| chars_to_bin(rest)] end

  ## adding two binary lists 
  def add_bin(x, []) do x end
  def add_bin(x,a) do
    Enum.zip_with(a, x, fn (i, j) -> i + j  end)
  end
  
  ## convert to an integer 
  def bin_to_int(bin) do
    List.foldl(bin, 0, fn (x, a) -> a*2 + x end)
  end


  def day3b() do
    seq = File.stream!("day3.csv") |>
      Enum.map( &chars_to_bin/1 )

    oxygen = rating(seq, &</2)
    scrubber = rating(seq, &>=/2)

    {bin_to_int(oxygen), bin_to_int(scrubber)}
  end

  def rating([done], _) do  done end
  def rating( seq, op) do 
    {k,l} = List.foldl(seq, {0,0}, fn ([b|_], {s,l}) -> {s+b,l+1} end)
    b = if op.(k, l-k) do
      0
    else
      1
    end
    ## Hmm, this is not tail recursive, should we change.
    [b|rating(filter_seq(seq, b), op)]
  end

  def filter_seq([], _) do [] end
  def filter_seq([[b|tail]|rest], b) do [tail|filter_seq(rest,b)] end  
  def filter_seq([_|rest], b) do filter_seq(rest,b) end

  ##==================================================================  

  def day4a() do
    [seq| brds] = String.split( File.read!("day4.csv"), "\n")
    seq = Enum.map(String.split(seq, ","), fn (nr) -> {n,_} = Integer.parse(nr); n end)
    brds = boards(brds)
    play(seq, brds)
  end

  def boards([]) do [] end
  def boards([_,r1,r2,r3,r4,r5|rest]) do
    [r1,r2,r3,r4,r5] = Enum.map([r1,r2,r3,r4,r5], fn (r) -> row(r) end)
    c1 = col(1, r1, r2, r3, r4, r5)
    c2 = col(2, r1, r2, r3, r4, r5)
    c3 = col(3, r1, r2, r3, r4, r5)
    c4 = col(4, r1, r2, r3, r4, r5)
    c5 = col(5, r1, r2, r3, r4, r5)        
    [[r1,r2,r3,r4,r5,c1,c2,c3,c4,c5]| boards(rest)]
  end

  def row(r) do
    Enum.map( String.split(r," ", trim: true), fn (nr) -> {n,_} = Integer.parse(nr); n end)
  end

  def col(1,r1,r2,r3,r4,r5) do
    [hd(r1),hd(r2),hd(r3),hd(r4),hd(r5)]
  end
  def col(c,r1,r2,r3,r4,r5) do
    col(c-1, tl(r1),tl(r2),tl(r3),tl(r4),tl(r5))
  end

  def  bingo(brd) do
    List.foldl(brd, false, fn (x,a) -> (a || [] == x) end)
  end

  # We have a winner if one of the boards is a winner

  def winner([]) do false end
  def winner([br|brds]) do
    if bingo(br) do
      br
    else
      winner(brds)
    end
  end

  # The score is now simply the sum of what is left in the rows (don't
  # count the columns as well since all squares occur twice).

  def score([r1,r2,r3,r4,r5|_], n) do
    List.foldl([r1,r2,r3,r4,r5], 0, fn (r,a) -> List.foldl(r, a,  fn(a,x) -> a + x end) end) * n
  end

  # So, now it is time to play. Call a number and filter the boards that
  # we have. If we have a winner we stop. 

  def play([], _) do [] end
  def play([n|seq], brds) do
    brds = Enum.map(brds, fn b -> Enum.map(b, fn r -> Enum.reject(r, fn x -> x == n end) end) end)
    win = winner(brds)
    if win do
      score(win, n)
    else
      play(seq,brds)
    end
  end

  def day4b() do
    [seq| brds] = String.split( File.read!("day4.csv"), "\n")
    seq = Enum.map(String.split(seq, ","), fn (nr) -> {n,_} = Integer.parse(nr); n end)
    brds = boards(brds)
    plau(seq, brds, :na)
  end

  def wanner([]) do {[],[]} end
  def wanner([brd|brds]) do
    {w,r} = wanner(brds)
    if bingo(brd) do
      {[brd|w], r}
    else
      {w, [brd|r]}
    end
  end

  def plau([], _, last) do last end
  def plau([n|seq], brds, last) do
    brds = Enum.map(brds, fn b -> Enum.map(b, fn r -> Enum.reject(r, fn x -> x == n end) end) end)
    {win, rest} = wanner(brds)
    case Enum.sort(Enum.map(win, fn (b) -> score(b,n) end), &>/2) do
      [] ->	
	plau(seq, rest, last)
      [last|_] ->
	plau(seq, rest, last)
    end
  end
  
  ##==================================================================

  def day5a() do
    seq = String.split( File.read!("day5.csv"), "\n") |>
      Enum.map(fn r ->
	[from, to] = String.split(r, "-> ")
	[x1,y1] = String.split(from, ",")
	[x2,y2] =  String.split(to, ",")
	{x1,_} = Integer.parse(x1)
	{y1,_} = Integer.parse(y1)
	{x2,_} = Integer.parse(x2)
	{y2,_} = Integer.parse(y2)
	{{x1,y1}, {x2,y2}}
      end) |>
      Enum.filter(fn ({{x1,y1}, {x2,y2}}) -> (x1 == x2) || (y1 == y2) end)
    twos(update(seq, %{}))
  end

  def twos(mtx) do
    List.foldl(Map.values(mtx), 0, fn (xv,a) -> List.foldl(Map.values(xv), a, fn (yv, a) -> if yv >= 2, do: a+1, else: a end) end)
  end

  def update([], mtx) do mtx end
  def update([{{x1,y1}, {x1, y2}}|rest], mtx) do
    mtx =  Map.update(mtx, x1,
      Enum.reduce(y1..y2, %{}, fn(yi, mx) -> Map.put(mx, yi, 1) end),
      fn (mx) ->
	Enum.reduce(y1..y2, mx,
	  fn (yi, my) ->
	    Map.update(my, yi, 1,  fn (n) -> n+1 end)
	  end)
	end)
    update(rest, mtx)
  end
  def update([{{x1,y1}, {x2, y1}}|rest], mtx) do
    mtx = Enum.reduce(x1..x2, mtx, fn (xi, mx) ->
	  Map.update(mx, xi, %{y1 => 1}, fn (my) ->
	    Map.update(my, y1, 1, fn (n) -> n+1 end) end) end)
    update(rest, mtx)
  end

  def day5b() do
    seq = String.split( File.read!("day5.csv"), "\n") |>
      Enum.map(fn r ->
	[from, to] = String.split(r, "-> ")
	[x1,y1] = String.split(from, ",")
	[x2,y2] =  String.split(to, ",")
	{x1,_} = Integer.parse(x1)
	{y1,_} = Integer.parse(y1)
	{x2,_} = Integer.parse(x2)
	{y2,_} = Integer.parse(y2)
	{{x1,y1}, {x2,y2}}
      end)
    twos(updateb(seq, %{}))
  end

  def updateb([], mtx) do mtx end
  def updateb([{{x1,y1}, {x1, y2}}|rest], mtx) do
    mtx =  Map.update(mtx, x1,
      Enum.reduce(y1..y2, %{}, fn(yi, mx) -> Map.put(mx, yi, 1) end),
      fn (mx) ->
	Enum.reduce(y1..y2, mx,
	  fn (yi, my) ->
	    Map.update(my, yi, 1,  fn (n) -> n+1 end)
	  end)
	end)
    updateb(rest, mtx)
  end
  def updateb([{{x1,y1}, {x2, y1}}|rest], mtx) do
    mtx = Enum.reduce(x1..x2, mtx, fn (xi, mx) ->
	  Map.update(mx, xi, %{y1 => 1}, fn (my) ->
	    Map.update(my, y1, 1, fn (n) -> n+1 end) end) end)
    updateb(rest, mtx)
  end
  def updateb([{{x1,y1}, {x2, y2}}|rest], mtx) do
    mtx = List.foldl( Enum.zip(x1..x2, y1..y2), mtx, fn ({xi,yi}, m) ->
      Map.update(m, xi, %{yi => 1}, fn (my) ->
	Map.update(my, yi, 1, fn (n) -> n+1 end) end) end)
    updateb(rest, mtx)
  end

  ##==================================================================


  def day6a() do
    pop =  String.split( File.read!("day6.csv"), ",") |>
      Enum.map(fn (nr) -> {n,_} = Integer.parse(nr); n end) |>
      List.foldl({0,0,0,0,0,0,0,0,0}, fn (n, pop) -> update_pop(pop, n) end)
    Tuple.sum(days(80, pop))
  end

  def update_pop(pop, n) do
    :erlang.setelement(n+1, pop, elem(pop, n)+1)
  end

  def days(0, pop) do pop end
  def days(n, {x0,x1,x2,x3,x4,x5,x6,x7,x8}) do
    days(n-1, {x1,x2,x3,x4,x5,x6,x7+x0,x8,x0})
  end


  def day6a() do
    pop =  String.split( File.read!("day6.csv"), ",") |>
      Enum.map(fn (nr) -> {n,_} = Integer.parse(nr); n end) |>
      List.foldl({0,0,0,0,0,0,0,0,0}, fn (n, pop) -> update_pop(pop, n) end)
    Tuple.sum(days(256, pop))
  end

end
