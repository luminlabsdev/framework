# Sprite

Handles the animation of spritesheets on image labels.

## Functions

### Animate <Badge type="warning" text="yields" />

Animates the given sprite to play like a GIF.

**Parameters**

* **image:** `ImageLabel`\
The image label that the sprite should be animated on

* **imageSize:** `Vector2`\
The size of the image

* **frames:** `Vector2`\
The amount of frames on both the X and Y axis

* **fps:** `number?`\
The amount of frames per second that the sprite should be played at. Defaults to 30

* **imageId:** `string?`\
The image id that the image label should be set to, defaults to the initial image of the image

**Returns**

* **void**

---

### StopAnimation

Stops the currently playing animation, if any.

**Parameters**

* **image:** `ImageLabel`\
The image label that should stop being animated

**Returns**

* **void**