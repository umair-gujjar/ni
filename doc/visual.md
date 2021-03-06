# Visualizing data
See also [examples.md](examples.md).

```sh
$ ni --js
http://localhost:8090
```

## Using the web interface
You can view the example in the screenshots by opening the following link on
your system while running `ni --js`:

```
http://localhost:8090/#%7B%22ni%22%3A%22n2E2p'r%20%24_%2C%20a%20for%200..199'%20p'r(a*10%20%2B%20%24_%2C%20b*10)%2C%20r(a*10%2C%20b*10%20%2B%20%24_)%20for%200..9'%20p'r%20a%2C%20sin(1%20%2B%20a%20%2F%20340)%20*%20cos(b*b%20%2F%2030000)%20%2B%20sin((a%20%2B%2050)*b%20%2F%20120000)%2C%20b'%22%2C%22vm%22%3A%5B1%2C0%2C0%2C0%2C0%2C1%2C0%2C0%2C0%2C0%2C1%2C0%2C0%2C0%2C0%2C1%5D%2C%22d%22%3A1.4%7D
```

![web ui](http://spencertipping.com/ni-jsplot-sinewave.png)

The UI consists of three main components: the ni command editor (top), the plot
(center), and a data preview (left). The data preview is normally hidden, but
you can hover over the left side of the screen to pop it out (click it to
toggle locking):

![data preview](http://spencertipping.com/ni-jsplot-sinewave2.png)

The view angle can be panned, rotated, and zoomed:

- **mouse drag:** pan
- **shift + drag:** 3D rotate
- **ctrl + drag, alt + drag, mousewheel:** zoom
