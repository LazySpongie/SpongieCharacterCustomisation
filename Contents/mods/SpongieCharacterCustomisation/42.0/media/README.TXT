
To see all of the parameters you can use when adding customisation, check media/lua/client/Examples.lua inside this mod.

Use the details pack and face pack as a template to understand how customisation options in this mod work.


See media/lua/shared/NPCs/SpnCharCustom_Bodylocations.lua for a list of all the bodylocations provided by this mod



The item tags you need to be aware of include:

    CharacterCustomisation - Not used currently but I added it just in case it's needed.

    Face - Required, the in-game character customisation screen will break otherwise.

    BodyDetail - Same as Face.
    
    RemoveOnZombification - Removes this item when a player dies while infected so they don't have a mismatched face texture as a zombie.

    CanHaveBlood - Blood and dirt on the player will be copied to the item. 
                    This is needed because the game always renders blood beneath clothing items.
                    Required for faces or any details that cover large parts of the body. Freckles and such are so subtle that it's not needed



Items that use the CanHaveBlood tag can't have any partial transparency in the texture.
    When blood gets on the item, the pixels that are partially transparent will become fully opaque and will look super broken.
