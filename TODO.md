* Work on custom network system
* Allow custom network system to batch unreliables (this is hard due to the 900 byte size limit)
* * *check if data is >= 800 bytes, if it is, batch the rest of the data into different calls until no data is left or the amount left can fit into 1 call*

* Create input module
* Make better for any kind of project