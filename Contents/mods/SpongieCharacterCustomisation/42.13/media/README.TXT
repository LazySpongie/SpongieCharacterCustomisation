
To see all of the parameters you can use when adding customisation, check media/lua/shared/Examples.lua inside this mod.

Use the details pack and face pack as a template to understand how customisation options in this mod work.


See media/lua/shared/CharacterCustomisation/SPNCC_Bodylocations.lua for a list of all the bodylocations provided by this mod



The item tags you need to be aware of include:

    Face - Required for faces.

    BodyDetail - Required for bodydetails.
    
    RemoveOnZombification - Removes this item when a player dies while infected so they don't have a mismatched face texture as a zombie.

    CanHaveBlood - Blood and dirt on the player will be copied to the item. 
                    This is needed because the game always renders blood beneath clothing items.
                    Required for faces or any details that cover large parts of the body.

                    CANNOT BE USED IF THE ITEM TEXTURE HAS ANY SEMI-TRANSPARENT PIXELS, THE TRANSPARENCY WILL BREAK IN-GAME
