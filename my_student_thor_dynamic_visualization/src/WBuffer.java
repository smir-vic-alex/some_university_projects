import java.awt.*;
import java.util.LinkedList;

/**
 * Created by Виктор on 11.03.2015.
 */
public class WBuffer {
    public static ScreenPoint[][] wBuf;
    public static int[][] screen;
    private static ScreenPoint[] xMin, xMax;
    private static LinkedList<ScreenPoint> pixel;

    /**
     * Запомнить пиксель, который должен рисоваться в данной точке
     * @param x экранная координата
     * @param y экранная координата
     * @param w значение в z-буфере
     * @param l цвет пикселя
     */
    private static void putPixel( int x, int y, double w, double l) {

        ScreenPoint p = new ScreenPoint();
        p.setX(x);
        p.setY(y);
        p.setW(w);
        p.setLight((int) Math.round(l));
        pixel.add(p);
    }

    /**
     * Алгоритм Брезенхема для растровой развертки отрезка модернизированный для работы с z-буфером.
     * Модернизация: 1) линейная интерполяция света и w значения по разности значений y координат 2) пиксель не рисутеся, а запоминается
     * @param p1 1-я точка
     * @param p2 2-я точка
     */
    public static void WLine( Vertex p1, Vertex p2) {
        int x1 = p1.getScreenPoint().getX();
        int y1 = p1.getScreenPoint().getY();
        int x2 = p2.getScreenPoint().getX();
        int y2 = p2.getScreenPoint().getY();
        int dx, dy, s, xend, yend, inc1, inc2, d, y, x;
        double w, dw, dl, light;

        dx = Math.abs(x1 - x2);
        dy = Math.abs(y1 - y2);

        if (dx > dy) {
            inc1 = 2 * dy;
            inc2 = 2 * (dy - dx);
            d = 2 * dy - dx;
            if (x1 < x2) {
                x = x1;
                y = y1;
                xend = x2;
                w = p1.getScreenPoint().getW();
                dw = p2.getScreenPoint().getW() - w;
                light = p1.getScreenPoint().getLight();
                dl = p2.getScreenPoint().getLight() - light;
                if (y1 < y2) {
                    s = 1;
                } else {
                    s = -1;
                }
            } else {
                x = x2;
                y = y2;
                xend = x1;
                w = p2.getScreenPoint().getW();
                dw = p1.getScreenPoint().getW() - w;
                light = p2.getScreenPoint().getLight();
                dl = p1.getScreenPoint().getLight() - light;
                if (y1 > y2) {
                    s = 1;
                } else {
                    s = -1;
                }
            }
            dw /= dy;
            dl /= dy;
            putPixel( x, y, w, light);
            while (x < xend) {
                x++;
                if (d > 0) {
                    w += dw;
                    y += s;
                    d += inc2;
                    light += dl;
                } else {
                    d += inc1;
                }
                putPixel( x, y, w, light);
            }
        } else {
            inc1 = 2 * dx;
            inc2 = 2 * (dx - dy);
            d = 2 * dx - dy;
            if (y1 < y2) {
                y = y1;
                x = x1;
                yend = y2;
                w = p1.getScreenPoint().getW();
                dw = p2.getScreenPoint().getW() - w;
                light = p1.getScreenPoint().getLight();
                dl = p2.getScreenPoint().getLight() - light;
                if (x1 < x2) {
                    s = 1;
                } else {
                    s = -1;
                }
            } else {
                x = x2;
                y = y2;
                yend = y1;
                w = p2.getScreenPoint().getW();
                dw = p1.getScreenPoint().getW() - w;
                light = p2.getScreenPoint().getLight();
                dl = p1.getScreenPoint().getLight() - light;
                if (x1 > x2) {
                    s = 1;
                } else {
                    s = -1;
                }
            }
            dw /= dy;
            dl /= dy;
            putPixel( x, y, w, light);
            while (y < yend) {
                y++;
                w += dw;
                light += dl;
                if (d > 0) {
                    x += s;
                    d += inc2;
                } else {
                    d += inc1;
                }
                putPixel( x, y, w, light);
            }
        }

    }

    /**
     * Вычисление максимального из четырех значений
     * @param x1
     * @param x2
     * @param x3
     * @param x4
     * @return
     */
    private static int getMax(int x1, int x2, int x3, int x4) {
        return Math.max(Math.max(x1, x2), Math.max(x3, x4));
    }

    /**
     * Вычисление минимального из четырех значений
     * @param x1
     * @param x2
     * @param x3
     * @param x4
     * @return
     */
    private static int getMin(int x1, int x2, int x3, int x4) {
        return Math.min(Math.min(x1, x2), Math.min(x3, x4));
    }

    /**
     * Вычисление координат, света и w значения для каждого пикселя по границе многогранника
     * @param p1
     * @param p2
     * @param p3
     * @param p4
     */
    private static void calculateBorder(Vertex p1, Vertex p2, Vertex p3, Vertex p4) {
        WLine( p1, p2);
        WLine( p2, p3);
        WLine( p3, p4);
        WLine( p4, p1);
    }

    /**
     * Вычисление света и w значения через линейное  интерполирование по разности x координат, заполнение z-буфера и цветов выводимых пикселей
     * @param p1
     * @param p2
     */
    private static void hLineW(ScreenPoint p1, ScreenPoint p2) {

        int y = p1.getY();
        double w = p1.getW();
        int dx = p2.getX() - p1.getX();
        double dw = 0;
        double dl = 0;
        double l = p1.getLight();
        int x = p1.getX();
        if (dx != 0) {
            dl = (p2.getLight() - p1.getLight()) / dx;
            dw = (p2.getW() - w) / dx;
        }
        while (x < p2.getX()) {
            if (wBuf[y][x] == null) {
                wBuf[y][x] = new ScreenPoint();
            }
            if (w > wBuf[y][x].getW()) {
                wBuf[y][x].setW(w);
                wBuf[y][x].setLight((int) Math.round(l));
                screen[y][x] = wBuf[y][x].getLight();
            }
            l += dl;
            w += dw;
            x++;
        }
    }

    /**
     * Вычисление значения z-буфера для грани с помошью YX-алгоритма развертки многоугольника
     * @param p1 вершина
     * @param p2 вершина
     * @param p3 вершина
     * @param p4 вершина
     */
    public static void fillFacetW( Vertex p1, Vertex p2, Vertex p3, Vertex p4) {

        int ymin = getMin(p1.getScreenPoint().getY(), p2.getScreenPoint().getY(), p3.getScreenPoint().getY(), p4.getScreenPoint().getY());
        int ymax = getMax(p1.getScreenPoint().getY(), p2.getScreenPoint().getY(), p3.getScreenPoint().getY(), p4.getScreenPoint().getY());

        if (ymax > ymin) {
            pixel = new LinkedList<ScreenPoint>();
            xMin = new ScreenPoint[600];
            xMax = new ScreenPoint[600];
            for (int i = ymin; i <= ymax; i++) {
                xMin[i] = new ScreenPoint();
                xMax[i] = new ScreenPoint();
                xMin[i].setX(Main.MAX_X + 1);
                xMax[i].setX(-1);
            }
            calculateBorder( p1, p2, p3, p4);
            for (ScreenPoint point : pixel) {
                if (point.getX() > xMax[point.getY()].getX()) {
                    xMax[point.getY()] = point;
                }
                if (point.getX() < xMin[point.getY()].getX()) {
                    xMin[point.getY()] = point;
                }
            }
            for (int i = ymin; i <= ymax; i++) {
                hLineW(xMin[i], xMax[i]);
            }

        }
    }

}
