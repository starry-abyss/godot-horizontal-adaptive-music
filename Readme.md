**Please note** that as of Godot 4.3 there is now a built-in way to implement adaptive music. This tool was made for Godot 3.

How to use
==========

This is the simple horizontal adaptive music implementation in GDScript.
It comes with some demo music tracks and setup.


Press debug buttons at top left corner to set the new music state and queue the music transition.
Note that not all transition combinations are possible (it's to be set up in 'music' scene).


To integrate with a game, one should add 'music' scene as autoload in project settings.
Then it's possible to call the new state as follows:

`get_node("/root/music").receiveEvent("attack")`


To hide debug buttons, uncheck 'Show Debug' in the music scene root node.


Music
=====

The music was composed by Bernard Machado for our Ludum Dare 41 game "Torn"


You can contact Bernard here:

    https://soundcloud.com/nudsmachado
    
    nudsmachadotrabalho [at] gmail.com

    
License
=============

You are free to use the code from this repository in any projects under MIT license.

See full code license text in License.txt
