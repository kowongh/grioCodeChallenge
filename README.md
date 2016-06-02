# grioCodeChallenge
This is an app that parses a GeoJSON file and finds the neighborhood for a given coordinate.

Simply open the app and type in the latitude and longitude, then press Find Neighborhood. You can add multiple saved locations.

Here are some test coordinates to try with the app:

345 Holyoke St. - Excelsior
37.727048, -122.408499

1612 45th Ave - Outer Sunset
37.756289, -122.504501

3641 Balboa St - Outer Richmond
37.775634, -122.498057

2324 Chestnut St. - Marina
37.800535, -122.441886

601 Howard St. - Financial District
37.786630, -122.398270

-
The app was created with one ViewController which has two main views. The first view contains two input textFields and a button, and the second view is a tableView for storing locations. I chose to work with <b>CGPoints</b>, because it seemed easier to work with instead of small two-index arrays and there was already built-in UIKit support for the containsPoint method.

In the <b>"readFile"</b> method, I cast the GeoJSON data to an NSDictionary.

Then in the <b>"parseNeighborhoods"</b> method which accepts a NSDictionary, I extracted the relevant information, like name and coordinates. 

Since the main geometry object being used was a <b>"MultiPolygon"</b> it had many nested arrays within the main object. A neighborhood can contain many polygons or regions, for instance the Marina contains 56 polygons, so we parse through those nested polygon arrays, format them as CGPoint arrays, and place them into an array of CGPoint arrays called "regions".

Finally, when the findButton is hit, we loop through each CGPoint array, create a polygon based on those CGPoints using <b>moveToPoint</b> and <b>addLineToPoint</b>, and check if it contains the point that was input from the textFields.

When there is a match, we add it to the <b>locationsFound</b> array of tuples (a name String and a CGPoint). Then we update the tableView with the new data.

Most of the UI was done through the main.storyboard and autolayout

-
INSTRUCTIONS: If you visit: https://raw.githubusercontent.com/codeforamerica/click_that_hood/master/public/data/san-francisco.geojson
you can find the list of neighborhoods in San Francisco in a GeoJson format. Every neighborhood is represented by a polygon.

You need to create a view that allows the user to insert the coordinates of a place (longitude and latitude). Given this input coordinates, write the logic to identify the associated neighborhood. When the neighborhood is identified, the user can add one or more Point of Interest (POI) to it*. You may want to create another view where the user can add a POI.

Please feel free to make architectural decisions and assumptions if any info is missing. You can also ask me questions before starting the code.
It's important you document anything can help me in the evaluation of the code (you don't need to write too much though). Finally, it's not particularly requested any fancy UI (like map visualization, etc.) unless you have some extra time left to spend on it.


*in this sample project, a POI is just a string (name of the POI) and one image (picture of the POI) - you can use a static placeholder for the image if you want
