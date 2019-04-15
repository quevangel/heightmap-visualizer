import std.stdio;

import derelict.sdl2.sdl;

int main(string[] arguments)
{
	writeln("Edit source/app.d to start your project.");
	DerelictSDL2.load();

	SDL_Window* window = SDL_CreateWindow("simple heightmap visualizer",
			SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			800, 600, 
			SDL_WINDOW_SHOWN);
	scope(exit)
	{
		SDL_DestroyWindow(window);
		window = null;
	}

	SDL_Delay(1000);

	return 0;
}
