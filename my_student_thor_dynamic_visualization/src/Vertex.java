/**
 * Created by Виктор on 11.03.2015.
 */

/**
 * Вершина с координатами в пространстве, на экране и нормалью
 */
public class Vertex {
    private ScreenPoint screenPoint;
    private Point3D normal;
    private Point3D point3D;

    public ScreenPoint getScreenPoint() {
        return screenPoint;
    }

    public void setScreenPoint(ScreenPoint screenPoint) {
        this.screenPoint = screenPoint;
    }

    public Point3D getNormal() {
        return normal;
    }

    public void setNormal(Point3D normal) {
        this.normal = normal;
    }

    public Point3D getPoint3D() {
        return point3D;
    }

    public void setPoint3D(Point3D point3D) {
        this.point3D = point3D;
    }
}
