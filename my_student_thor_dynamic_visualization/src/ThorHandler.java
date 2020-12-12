/**
 * Created by Виктор on 11.03.2015.
 */

import java.util.LinkedList;

/**
 * Инициализирует и вычисляет все начальные координаты необходимые для построения и закраски тора
 */
public class ThorHandler {

    private Point3D point3D;
    private final int difLight = 150;
    private final int activeLight = 100;
    private static double x,y,z;

    /**
     * Инициализация всех точек тора, а так же граней, нормалей и света по ним
     * @param thor
     */
    public void makeThor(Thor thor) {

        thor.vertexes = new Vertex[Thor.iPoints][Thor.jPoints];
        initVertexes(thor.vertexes);
        thor.facets = new LinkedList<Facet>();
        initFaces(thor.facets);
        thor.innerPoints = new Point3D[Thor.iPoints];
        initInnerPoints(thor.vertexes, thor.innerPoints);
        initNormals(thor.vertexes, thor.innerPoints);
        initLight(thor.vertexes);

    }

    /**
     * Вычисление света для каждой точки
     * @param vertexes - матрица точек
     */
    private void initLight(Vertex[][] vertexes) {

        for (int i = 0; i < Thor.iPoints; i++) {
            for (int j = 0; j < Thor.jPoints; j++) {
                light(vertexes[i][j]);
            }
        }
    }

    /**
     * Вычисление света для точки
     * @param vertex
     */
    private void light(Vertex vertex) {

        double lightPosition = Math.sqrt(3);
        double r1 = Math.sqrt(vertex.getNormal().getX() * vertex.getNormal().getX() +
                vertex.getNormal().getY() * vertex.getNormal().getY() + vertex.getNormal().getZ() * vertex.getNormal().getZ());
        double r2 = Math.sqrt(1 + lightPosition + 1);
        double cosA = Math.abs((vertex.getNormal().getX() + vertex.getNormal().getY() * lightPosition + vertex.getNormal().getZ()) / (r1 * r2));
        if (cosA > 1) {
            cosA = 1;
        } else if (cosA < -1) {
            cosA = -1;
        }
        vertex.getScreenPoint().setLight((int) Math.round(difLight + activeLight * cosA));
    }

    /**
     * Повернуть точку относительно оси OY
     * @param point3D точка
     * @param rot угол поворота
     * @return
     */
    private static Point3D rotatePointOnY(Point3D point3D, double rot) {

         x = point3D.getX();
         y = point3D.getY();
         z = point3D.getZ();
        point3D.setX(x * Math.cos(rot) - z * Math.sin(rot));
        point3D.setY(y);
        point3D.setZ(x * Math.sin(rot) + z * Math.cos(rot));

        return point3D;
    }

    /**
     * Поворот всех точек относительно оси OY
     * @param thor
     * @param angle угол поворота
     */
    public void rotateY(Thor thor, double angle) {

        for (int i = 0; i < Thor.iPoints; i++) {
            for (int j = 0; j < Thor.jPoints; j++) {
                thor.vertexes[i][j].setPoint3D(rotatePointOnY(thor.vertexes[i][j].getPoint3D(), angle));
                thor.vertexes[i][j].setScreenPoint(getProectionPoint(thor.vertexes[i][j].getPoint3D()));
                thor.vertexes[i][j].setNormal(rotatePointOnY(thor.vertexes[i][j].getNormal(), angle));

            }
            thor.innerPoints[i] = rotatePointOnY(thor.innerPoints[i], angle);
        }
        initLight(thor.vertexes);
    }

    /**
     * Повернуть точку относительно оси OX
     * @param point3D точка
     * @param rot угол поворота
     * @return
     */
    private static Point3D rotatePointOnX(Point3D point3D, double rot) {

         x = point3D.getX();
         y = point3D.getY();
         z = point3D.getZ();
        point3D.setX(x);
        point3D.setY(y * Math.cos(rot) + z * Math.sin(rot));
        point3D.setZ(-y * Math.sin(rot) + z * Math.cos(rot));
        return point3D;
    }

    /**
     * Поворот всех точек относительно оси OX
     * @param thor
     * @param angle угол поворота
     */
    public void rotateX(Thor thor, double angle) {

        for (int i = 0; i < Thor.iPoints; i++) {
            for (int j = 0; j < Thor.jPoints; j++) {
                thor.vertexes[i][j].setPoint3D(rotatePointOnX(thor.vertexes[i][j].getPoint3D(), angle));
                thor.vertexes[i][j].setScreenPoint(getProectionPoint(thor.vertexes[i][j].getPoint3D()));
                thor.vertexes[i][j].setNormal(rotatePointOnX(thor.vertexes[i][j].getNormal(), angle));

            }
            thor.innerPoints[i] = rotatePointOnX(thor.innerPoints[i], angle);
        }
        initLight(thor.vertexes);
    }

    /**
     * Вычисление вектора для каждой точки
     * Вектор: точка минус центр образующей окружности
     * @param vertexes - матрица точек
     * @param innerPoints - центры образующих окружностей
     */
    private void initNormals(Vertex[][] vertexes, Point3D[] innerPoints) {

        for (int i = 0; i < Thor.iPoints; i++) {
            for (int j = 0; j < Thor.jPoints; j++) {
                point3D = new Point3D();
                point3D.setX(vertexes[i][j].getPoint3D().getX() - innerPoints[i].getX());
                point3D.setY(vertexes[i][j].getPoint3D().getY() - innerPoints[i].getY());
                point3D.setZ(vertexes[i][j].getPoint3D().getZ() - innerPoints[i].getZ());
                vertexes[i][j].setNormal(point3D);
            }
        }
    }

    /**
     * Вычисление центров образующих окружностей
     * @param vertexes - матрица точек
     * @param innerPoints - центры образующих окружностей
     */
    private void initInnerPoints(Vertex[][] vertexes, Point3D[] innerPoints) {

        for (int i = 0; i < Thor.iPoints; i++) {
            x = 0;
            y = 0;
            z = 0;
            for (int j = 0; j < Thor.jPoints; j++) {
                x += vertexes[i][j].getPoint3D().getX();
                y += vertexes[i][j].getPoint3D().getY();
                z += vertexes[i][j].getPoint3D().getZ();
            }
            innerPoints[i] = new Point3D();
            innerPoints[i].setX(x / Thor.jPoints);
            innerPoints[i].setY(y / Thor.jPoints);
            innerPoints[i].setZ(z / Thor.jPoints);
        }
    }

    /**
     * Проецирование точки на экран
     * @param point3D - точка в пространстве
     * @return точка на плоскости
     */
    private ScreenPoint getProectionPoint(Point3D point3D) {
        int dx = 250;
        int dy = 250;
        ScreenPoint point2D = new ScreenPoint();
        point2D.setX((int) Math.round(point3D.getX() / (1 - point3D.getZ() / Thor.z0) + dx));
        point2D.setY((int) Math.round(point3D.getY() / (1 - point3D.getZ() / Thor.z0) + dy));
        point2D.setW(1 / (Thor.z0 - point3D.getZ()));

        return point2D;
    }

    /**
     * Вычисление координат вершин в пространстве и их проецирование на экран
     * @param vertexes
     */
    private void initVertexes(Vertex[][] vertexes) {
        double I_ANGLE = (2 * Math.PI) / Thor.iPoints;
        double J_ANGLE = (2 * Math.PI) / Thor.jPoints;
        double uAngle;
        double vAngle;
        for (int i = 0; i < Thor.iPoints; i++) {
            for (int j = 0; j < Thor.jPoints; j++) {
                vertexes[i][j] = new Vertex();
                uAngle = J_ANGLE * j;
                vAngle = I_ANGLE * i;
                point3D = new Point3D();
                point3D.setX((Thor.R + Thor.r * Math.cos(uAngle)) * Math.cos(vAngle));
                point3D.setY((Thor.R + Thor.r * Math.cos(uAngle)) * Math.sin(vAngle));
                point3D.setZ(Thor.r * Math.sin(uAngle));
                vertexes[i][j].setPoint3D(point3D);
                vertexes[i][j].setScreenPoint(getProectionPoint(point3D));
            }
        }

    }

    /**
     * Инициализация грани и присваивание для каждой ее вершины номера точки из матрицы
     * @param i0
     * @param j0
     * @param i1
     * @param j1
     * @param i2
     * @param j2
     * @param i3
     * @param j3
     * @return
     */
    private Facet getInitFacet(int i0, int j0, int i1, int j1, int i2, int j2, int i3, int j3) {

        Facet facet = new Facet();
        facet.setVertexNumber(new int[4][2]);
        facet.getVertexNumber()[0][0] = i0;
        facet.getVertexNumber()[0][1] = j0;
        facet.getVertexNumber()[1][0] = i1;
        facet.getVertexNumber()[1][1] = j1;
        facet.getVertexNumber()[2][0] = i2;
        facet.getVertexNumber()[2][1] = j2;
        facet.getVertexNumber()[3][0] = i3;
        facet.getVertexNumber()[3][1] = j3;

        return facet;
    }

    /**
     * Вычисление номеров вершин для каждой грани
     * @param facets
     */
    private void initFaces(LinkedList<Facet> facets) {

        for (int i = 0; i < Thor.iPoints - 1; i++) {
            for (int j = 0; j < Thor.jPoints - 1; j++) {
                facets.add(getInitFacet(i, j, i + 1, j, i + 1, j + 1, i, j + 1));
            }
            facets.add(getInitFacet(i, Thor.jPoints - 1, i + 1, Thor.jPoints - 1, i + 1, 0, i, 0));
        }
        for (int j = 0; j < Thor.jPoints - 1; j++) {
            facets.add(getInitFacet(Thor.iPoints - 1, j, Thor.iPoints - 1, j + 1, 0, j + 1, 0, j));
        }
        facets.add(getInitFacet(Thor.iPoints - 1, Thor.jPoints - 1, 0, Thor.jPoints - 1, 0, 0, Thor.iPoints - 1, 0));
    }

}
