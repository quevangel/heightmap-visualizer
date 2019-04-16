import std.stdio: writeln, stderr;
import std.string: fromStringz;
import core.stdc.stdlib: exit;
import std.conv: text;

import derelict.sdl2.sdl: 
	DerelictSDL2,
	SDL_Init, SDL_INIT_VIDEO, 
	SDL_GL_CONTEXT_MAJOR_VERSION, SDL_GL_CONTEXT_MINOR_VERSION, SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE, SDL_GLattr, SDL_GL_SetAttribute, SDL_GL_GetAttribute,
	SDL_Window, SDL_CreateWindow, SDL_DestroyWindow, SDL_WINDOWPOS_CENTERED, SDL_WINDOW_SHOWN, SDL_WINDOW_OPENGL, SDL_GL_SwapWindow,
	SDL_GL_CreateContext, SDL_GL_DeleteContext,
	SDL_Delay,
	SDL_GetError, SDL_ClearError;

import derelict.opengl:
	DerelictGL3, GLVersion, 
	glClearColor, glClear, GL_COLOR_BUFFER_BIT;

int main(string[] arguments)
{
	// First commandline argument validation.
	if(arguments.length != 2)
	{
		printHelp(arguments);
		return -1;
	}
	assert(arguments.length == 2);
	//

	// Derelict loading.
	DerelictSDL2.load();
	DerelictGL3.load();
	//

	// SDL2 video system initialization.
	if(SDL_Init(SDL_INIT_VIDEO) < 0)
		dieForError(__LINE__, "Unable to initialize video system for SDL2.");
	//

	// Desired opengl attributes setting.
	const int[SDL_GLattr] desiredGlAttributes = [
		SDL_GL_CONTEXT_MAJOR_VERSION: 3, 
		SDL_GL_CONTEXT_MINOR_VERSION: 3, 
		SDL_GL_CONTEXT_PROFILE_MASK: cast(int)SDL_GL_CONTEXT_PROFILE_CORE
	];

	foreach(attributeName, attributeValue; desiredGlAttributes)
		SDL_GL_SetAttribute(attributeName, attributeValue);
	//

	// Window creation.
	const window = SDL_CreateWindow("simple heightmap visualizer",
			SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
			800, 600, 
			SDL_WINDOW_SHOWN | SDL_WINDOW_OPENGL);
	scope(exit)
	{
		assert(window !is null);
		SDL_DestroyWindow(cast(SDL_Window*)window);
	}
	if(window is null)
		dieForError(__LINE__, text("Error creating window: ", sdlError));
	assert(window !is null);
	//
	
	// Opengl context creation.
	const context = SDL_GL_CreateContext(cast(SDL_Window*) window);
	scope(exit)
	{
		assert(context !is null);
		SDL_GL_DeleteContext(cast(void*) context);
	}
	if(context is null)
		dieForError(__LINE__, text(" SDL Fatal error: ", sdlError));
	assert(context !is null);
	//

	// DerelictGL3 reloading.
	auto loadedVersion = DerelictGL3.reload();
	writeln("DerelictGL3 loadedVersion = ", loadedVersion);
	if(loadedVersion < GLVersion.gl33)
		dieForError(__LINE__, text("Fatal error reloading derelict-gl3 module: Version too low ", loadedVersion));
	//

	// Opengl attributes verification.
	int[SDL_GLattr] gottenGlAttributes;
	foreach(attributeName, desiredAttributeValue; desiredGlAttributes)
	{
		gottenGlAttributes[attributeName] = 0;
		SDL_GL_GetAttribute(attributeName, &gottenGlAttributes[attributeName]);
	}
	foreach(attributeName, desiredAttributeValue; desiredGlAttributes)
		if(gottenGlAttributes[attributeName] != desiredAttributeValue)
			dieForError(__LINE__, text("Fatal error in opengl context attributes! Gotten ", gottenGlAttributes, " Desired: ", desiredGlAttributes));
	//

	// Draw yellow window.
	glClearColor(1.0, 1.0, 0.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	SDL_GL_SwapWindow(cast(SDL_Window*) window);
	// 

	// ditto.
	SDL_Delay(1000);

	return 0;
}

nothrow void printHelp(string[] arguments) 
{
	try
		writeln("Use: ", arguments[0], " HEIGHTMAP_FILENAME");
	catch(Exception e)
		exit(13);
}

nothrow string sdlError() 
{
	string errorMessage = (cast(string) SDL_GetError().fromStringz).dup;
	if(errorMessage.length != 0)
		SDL_ClearError();

	return errorMessage;
}

nothrow void dieForError(int line, string message, int status = 1)
{
	try
	{
		stderr.writeln("ON LINE ", line, ": ", message);
	}
	catch(Exception e)
	{
		try
			writeln("ERROR WRITING TO STDERR ", e.msg);
		catch(Exception e)
			exit(13);
		exit(13);
	}

	exit(status);
}
