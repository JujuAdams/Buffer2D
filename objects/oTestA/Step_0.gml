if (keyboard_check(vk_control))
{
    
}
else if (keyboard_check(vk_shift))
{
    
}
else
{
    if (keyboard_check_pressed(vk_up   )) bufferGrid.Shift( 0, -1);
    if (keyboard_check_pressed(vk_down )) bufferGrid.Shift( 0,  1);
    if (keyboard_check_pressed(vk_left )) bufferGrid.Shift(-1,  0);
    if (keyboard_check_pressed(vk_right)) bufferGrid.Shift( 1,  0);
    
    if (keyboard_check_pressed(ord("I"))) bufferGrid.Shift(-1, -1);
    if (keyboard_check_pressed(ord("O"))) bufferGrid.Shift( 1, -1);
    if (keyboard_check_pressed(ord("K"))) bufferGrid.Shift(-1,  1);
    if (keyboard_check_pressed(ord("L"))) bufferGrid.Shift( 1,  1);
}