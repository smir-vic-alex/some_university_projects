import javax.swing.*;
import java.awt.*;
import java.awt.event.MouseEvent;
import java.awt.event.MouseMotionAdapter;

/**
 * Created by Виктор on 11.03.2015.
 */
public class Main extends JPanel {

    final static int MAX_X = 600;
    final static int MAX_Y = 600;
    public Thor thor;
    public ThorHandler thorHandler;
    public Graphics graphics;
    private double angle = 0.07;
    private Vertex p1, p2, p3, p4;
    private final int r = 0;
    private final int g = 1;
    private final int b = 0;

    /**
     * метод отрисовки тора. В начале определяется с помощью z-буфера видимость каждой грани, потом попиксельно выводится картинка
     * @param graphics
     * @param thor
     */
    void draw(Graphics graphics, Thor thor) {

        WBuffer.wBuf = new ScreenPoint[MAX_Y][MAX_X];
        WBuffer.screen = new int[Main.MAX_Y][Main.MAX_X];

        for (Facet facet : thor.facets) {
            p1 = thor.vertexes[facet.getVertexNumber()[0][0]][facet.getVertexNumber()[0][1]];
            p2 = thor.vertexes[facet.getVertexNumber()[1][0]][facet.getVertexNumber()[1][1]];
            p3 = thor.vertexes[facet.getVertexNumber()[2][0]][facet.getVertexNumber()[2][1]];
            p4 = thor.vertexes[facet.getVertexNumber()[3][0]][facet.getVertexNumber()[3][1]];
            WBuffer.fillFacetW(p1, p2, p3, p4);
        }
        for (int i = 0; i < MAX_Y; i++) {
            for (int j = 0; j < MAX_X; j++) {
                if (WBuffer.screen[j][i] > 0) {
                    graphics.setColor(new Color(WBuffer.screen[j][i]*r,WBuffer.screen[j][i]*g ,WBuffer.screen[j][i]*b ));
                    graphics.drawLine(j, i, j, i);
                }
            }
        }
    }


    @Override
    protected void paintComponent(Graphics g) {
        super.paintComponent(g);
        this.graphics = g;
        draw(g, thor);
    }

    public Main() {
        JFrame frame = new JFrame("Thor");
        frame.setLocation(150, 150);
        frame.setMinimumSize(new Dimension(MAX_X, MAX_Y));
        frame.setDefaultCloseOperation(WindowConstants.EXIT_ON_CLOSE);
        frame.getContentPane().add(this);
        frame.pack();
        frame.setVisible(true);

        frame.addMouseMotionListener(new MouseMotionAdapter() {
            int oldX;
            int oldY;
            int newX;
            int newY;

            /**
             * Поворот тора относительно перетаскиваемой мышки с зажатой кнопкой
             * @param e
             */
            @Override
            public void mouseDragged(MouseEvent e) {
                super.mouseDragged(e);
                oldX = newX;
                oldY = newY;
                newX = e.getX();
                newY = e.getY();
                if (oldX < newX) {
                    if (angle < 0) {
                        angle = -angle;
                    }
                    thorHandler.rotateX(thor, angle);
                }else if (oldX>newX){
                    if (angle > 0) {
                        angle = -angle;
                    }
                    thorHandler.rotateX(thor, angle);
                }
                if (oldY < newY) {
                    if (angle > 0) {
                        angle = -angle;
                    }
                    thorHandler.rotateY(thor, angle);
                }else if (oldY>newY){
                    if (angle < 0) {
                        angle = -angle;
                    }
                    thorHandler.rotateY(thor, angle);
                }
                repaint();
            }
        });

        thorHandler = new ThorHandler();
        thor = new Thor();
        thorHandler.makeThor(thor);
        try {
            Thread.sleep(50);
        }catch (InterruptedException e){

        }

    }

    public static void main(String[] args) {
        new Main();
    }
}
