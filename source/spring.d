module spring;
import button;
import io;
import puzzle;
import text_zone;
import zone;

import core.stdc.stdlib;
import std.exception;
import std.stdio;
import std.string;

pragma (lib, "dallegro5");
pragma (lib, "allegro");
pragma (lib, "allegro_font");
pragma (lib, "allegro_image");
pragma (lib, "allegro_primitives");
pragma (lib, "allegro_ttf");

import allegro5.allegro;
import allegro5.allegro_font;
import allegro5.allegro_image;
import allegro5.allegro_primitives;
import allegro5.allegro_ttf;

immutable int MAX_X = 800;
immutable int MAX_Y = 600;
immutable real FPS = 60.0;

ALLEGRO_DISPLAY * display;
ALLEGRO_EVENT_QUEUE * eventQueue;
ALLEGRO_TIMER * drawTimer;
ALLEGRO_FONT * textFont;
ALLEGRO_FONT * buttonFont;
ALLEGRO_FONT * captionFont;

auto toAllegroUstr (const char [] s)
{
	auto tempUstrInfo = new ALLEGRO_USTR_INFO;
	return al_ref_buffer (tempUstrInfo, s.ptr, s.length);
}

void init ()
{
	enforce (al_init ());
	enforce (al_init_font_addon ());
	enforce (al_init_image_addon ());
	enforce (al_init_primitives_addon ());
	enforce (al_init_ttf_addon ());
	enforce (al_install_keyboard ());
	enforce (al_install_mouse ());

	display = al_create_display (MAX_X, MAX_Y);
	enforce (display);

	drawTimer = al_create_timer (1.0 / FPS);
	enforce (drawTimer);
	al_start_timer (drawTimer);

	textFont = al_load_ttf_font ("data/EBGaramond.otf", 24, 0);
	enforce (textFont);

	buttonFont = al_load_ttf_font ("data/EBGaramond.otf", 30, 0);
	enforce (buttonFont);

	captionFont = al_load_ttf_font ("data/EBGaramond.otf", 48, 0);
	enforce (captionFont);

	eventQueue = al_create_event_queue ();
	enforce (eventQueue);

	al_register_event_source (eventQueue, al_get_keyboard_event_source ());
	al_register_event_source (eventQueue, al_get_mouse_event_source ());
	al_register_event_source (eventQueue, al_get_timer_event_source (drawTimer));
	al_register_event_source (eventQueue, al_get_display_event_source (display));
}

Io ioRoot;

void draw ()
{
	al_clear_to_color (al_map_rgb_f (0.0, 0.0, 0.0));
	enforce (ioRoot !is null);
	ioRoot.draw ();
	al_flip_display ();
}

bool isFinished = false;

auto prepareMenu ()
{
	auto menu = new Zone (null, 0, 0, MAX_X, MAX_Y,
	    al_map_rgb_f (0.2, 0.3, 0.1));
	auto buttonColor = al_map_rgb_f (0.1, 0.3, 0.5);
	auto caption = new TextZone (menu,
	    (MAX_X - 200) / 2, 110, 200, 50,
	    al_map_rgba_f (0.0, 0.0, 0.0, 0.0), al_map_rgb_f (0.4, 0.9, 0.1),
	    captionFont, "SPRING".toAllegroUstr ());
	auto ruButton = new Button (menu,
	    MAX_X * 1 / 4 - 120 / 2, 250, 120, 40,
	    buttonColor, al_map_rgb_f (0.9, 0.9, 0.5),
	    buttonFont, "Тютчев".toAllegroUstr (),
	    (int posX, int posY) {});
	auto enButton = new Button (menu,
	    MAX_X * 3 / 4 - 120 / 2, 250, 120, 40,
	    buttonColor, al_map_rgb_f (0.7, 0.7, 0.7),
	    buttonFont, "---".toAllegroUstr (),
	    (int posX, int posY) {});
	auto exitButton = new Button (menu,
	    (MAX_X - 120) / 2, 325, 120, 40,
	    buttonColor, al_map_rgb_f (0.9, 0.5, 0.5),
	    buttonFont, "Exit".toAllegroUstr (),
	    (int posX, int posY) {isFinished = true;});
	return menu;
}

void mainLoop ()
{
	auto menu = prepareMenu ();
//	auto puzzle = new Puzzle ();
	ioRoot = menu;
	draw ();

	isFinished = false;
	while (!isFinished)
	{
		ALLEGRO_EVENT currentEvent;
		al_wait_for_event (eventQueue, &currentEvent);

		switch (currentEvent.type)
		{
			case ALLEGRO_EVENT_DISPLAY_CLOSE:
				isFinished = true;
				break;

			case ALLEGRO_EVENT_MOUSE_BUTTON_DOWN:
				if (currentEvent.mouse.button == 1)
				{
					auto x = currentEvent.mouse.x;
					auto y = currentEvent.mouse.y;
					ioRoot.click (x, y);
				}
				break;

			case ALLEGRO_EVENT_MOUSE_BUTTON_UP:
				if (currentEvent.mouse.button == 1)
				{
					auto x = currentEvent.mouse.x;
					auto y = currentEvent.mouse.y;
					ioRoot.unclick (x, y);
				}
				break;

			case ALLEGRO_EVENT_TIMER:
				draw ();
				break;

			default:
				break;
		}
	}
}

void happyEnd ()
{
	al_destroy_event_queue (eventQueue);
	al_destroy_font (captionFont);
	al_destroy_font (buttonFont);
	al_destroy_font (textFont);
	al_destroy_timer (drawTimer);
	al_destroy_display (display);

	al_shutdown_font_addon ();
	al_shutdown_image_addon ();
	al_shutdown_primitives_addon ();
	al_shutdown_ttf_addon ();

	exit (EXIT_SUCCESS);
}

int main (string [] args)
{
	return al_run_allegro (
	{
		init ();
		mainLoop ();
		happyEnd ();
		return 0;
	});
}
