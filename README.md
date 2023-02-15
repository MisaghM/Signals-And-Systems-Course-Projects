# Signals And Systems Course Projects

- [Signals And Systems Course Projects](#signals-and-systems-course-projects)
  - [Project 1: License Plate Detection](#project-1-license-plate-detection)
  - [Project 3: Sending Data via Signals](#project-3-sending-data-via-signals)

## Project 1: License Plate Detection

The project is split into 2 parts detecting English plates and Persian plates.  
Most of the work is put into the Persian plate detection.

First of all, a map set is manually created using pictures of random plates and is split into alphabet and numbers.  
The `make_letterset` function is ran which reads the map set and creates a struct with 2 members: alphabet and numbers.  
The result of the function is cached in `LICENSE_LETTERS.mat` and is used for the next time running the program.

An image is chosen by the user, and now the license plate's location has to be detected.  
**3 methods** are used to detect the location of the license plate:

- `detectplate_bluestrip`:  
  Looking at Persian license plates, we can see that they all share a blue strip with the country's flag on the left side of the plate.  
  Here, the image is searched for the blue strip using 2D cross-correlation.  
  There are 2 versions of the `bluestrip.png` file. This is because the cross-correlation does not resize the image to find the best fit.
- `detectplate_aspect`:  
  Here, the image is split into regions and the ones which have a aspect ratio close to the license plate's (which is about 4) are chosen.  
  From these chosen regions, the ones which have blue color on the left side are returned.
- `detectplate_color_changes`:  
  Since a license plate consists of letters over a white background, there are many extreme color changes happening in a row of the image over the plate.  
  In this method, the image rows which have a hint of blue are filtered by the ones having a lot of color changes.  
  The rows which do not have enough color changes are removed, and the image is split into regions. Additionally, filtering by aspect ratio can be done here.  
  The close regions are merged together and the result is returned.

Having detected the possible locations of the license plate, the characters inside each of the suspected regions are recognized. The one having the most characters is taken as the final result.  
To recognize the characters (`recognize_characters` function), the plate is turned into segments, and some filtering such as removing high aspect ratio parts is applied.  
Now correlation is done on each segment to see which letter from the map set is the best match for the character.  
Knowing which character we are at, the dots of the alphabet letter of the plate are also handled.

The output is printed and also put in the `license_plate.txt` file.

## Project 3: Sending Data via Signals

This project is made of 4 parts:

- **Part 1 & 2:**  
  The following wanted signals:  
  $cos(10\pi t)$, $\Pi(t)$, $cos(10\pi t)\Pi(t)$, $cos(30\pi t + \frac{\pi}{4})$,  $\sum_{-9}^9{\Pi(t-2k)}$, $\delta(t)$, and $x(t)=1$  
  and their Fourier transform is sampled and plotted.  
  It is then theoretically calculated in the report.
- **Part 3:**  
  In this part, we will send a string encoded in a signal's amplitude, add noise to it, and then decode it back to the original string.  
  First of all, a map set is created and stored in `mapset.mat` which maps characters to 5 bit numbers.  
  Using `coding_amp`, a string is encoded in a sine wave. The function takes a `bitrate` input which determines how many bits will be encoded in each sine wave using the amplitude.  
  Now random noise is added to the signal and is decoded using `decoding_amp`.  
  We will see after testing that on a fixed signal domain, the higher the bitrate is, the more sensitive it will be to noise and will have more error when decoding.
- **Part 4:**  
  This part is similar to the previous, except instead of using the signal's amplitude for encoding, the signal's frequency is used. (`coding_freq` and `decoding_freq`)  
  Just like the previous part, we will see after testing that on a fixed signal bandwidth, the higher the bitrate, the higher the decoding error rate.
