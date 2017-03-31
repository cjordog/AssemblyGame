This is my assembly game that I created in March 2017.

It runs on Mac on possibly Linux OS, it was developed on a mac.

I used FreeBSD x86 assembly running on MacOS.


==================================================
**************   Run Instructions   **************
==================================================

In order to run:

	1.	clone the project
	2.	make
	3.	run the executable with either "make run" or "./game"



==================================================
******************   Gameplay   ******************
==================================================


The game is a textbased game, where the objective is to type all
the letters alphabetically, one at a time, pressing enter in
between each letter press. The game times your run and compares
your current time to the all time high score. High Scores are held
in highscores.txt. To clear highscores, just remove this file. 

After running the executable, press enter to begin the game, and 
wait for the countdown to finish, then begin typing as fast as
possible. Upon finish, your score is displayed, and you can either
type 'y' to play again, or 'n' to quit the game. High scores are saved
across runs.



==================================================
****************   Project Info   ****************
==================================================


My choice to develop in assembly on a mac severely limited the amount of 
access I had to low level assembly calls, since Mac's disable most of 
the system call interrupts except one, int 80h, that allows for read, write,
and other very basic system calls. I wanted to see how far I could get
using only Mac assembly. If I ported this to Windows, I would be able
to accomplish quite a bit more in terms of graphics and hardware
access, but I don't have the means to accomplish this right now.

The biggest obstacles I had to overcome with this project came in me realizing
how limited Mac assembly calls really were. I originally wanted to make a snake
game, but realized that graphics calls were disabled. So I switched to wanting
to make a text based pong game, but realized that calls to access the keyboard 
buffer were disabled, so I could not get realtime input. So I switched to wanting
to make some sort of text based game. I ended up with this as a result.

The next biggest obstacle was in the creation of the timer. Since I could not 
multithread this assembly program without several months of research into low
level assembly calls, which are probably disabled on Mac anyways, I had to come up
with some other solution. I simply made stdin nonblocking, which may sound trivial,
but becomes a very complex task in assembly. 

I also struggled a lot with file input and output. Again, this is such a trivial
task in C, but in assembly it takes many many hours of work. I simply wanted
to store high scores as a number in a file, but storing a number is very difficult.
You have to write each bit one by one to the file in binary, using bitmasks to
read the bits off one by one. Reading from the file is difficult too. I had to check 
if there was already a score in the file, so I tried using lseek, but this ended up 
not working correctly, so I noticed the pattern that if there is nothing in the file,
the read call will read just 1's. So if the high score thats read in is a -1,
I simply reset the score to maxInt, so the next play will always beat it.

This project really helped me understand a lot about how compilers work, especially
after my code optimization began. I included the file oldsource.asm to see the 
comparison with my un-optimized assembly and my more finished optimized assembly.
It was a good experience for learning how computers work on the low level, and
it was definitely a lot of fun.