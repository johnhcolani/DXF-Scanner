#ifndef CORNER_DETECTOR_H
#define CORNER_DETECTOR_H

#include <vector>
#include <opencv2/opencv.hpp>

struct Point2D {
    double x;
    double y;
};

struct Line {
    Point2D start;
    Point2D end;
};

struct Arc {
    Point2D center;
    double radius;
    double startAngle;
    double endAngle;
};

struct Circle {
    Point2D center;
    double radius;
};

struct GeometricPrimitives {
    std::vector<Line> lines;
    std::vector<Arc> arcs;
    std::vector<Circle> circles;
};

class CornerDetector {
public:
    CornerDetector();
    ~CornerDetector();
    
    // Main function to process image and extract geometric primitives
    GeometricPrimitives processImage(const std::vector<uint8_t>& imageData, 
                                   int width, int height, int channels);
    
    // Corner detection using Harris corner detector
    std::vector<Point2D> detectCorners(const cv::Mat& image);
    
    // Line detection using Hough transform
    std::vector<Line> detectLines(const cv::Mat& image, const std::vector<Point2D>& corners);
    
    // Circle detection using HoughCircles
    std::vector<Circle> detectCircles(const cv::Mat& image);
    
    // Arc detection by analyzing connected corners
    std::vector<Arc> detectArcs(const cv::Mat& image, const std::vector<Point2D>& corners);
    
    // Convert image data to OpenCV Mat
    cv::Mat imageDataToMat(const std::vector<uint8_t>& imageData, 
                          int width, int height, int channels);
    
    // Convert Mat back to image data
    std::vector<uint8_t> matToImageData(const cv::Mat& mat);
    
private:
    // Helper functions
    double calculateDistance(const Point2D& p1, const Point2D& p2);
    double calculateAngle(const Point2D& p1, const Point2D& p2, const Point2D& p3);
    bool isPointOnLine(const Point2D& point, const Line& line, double tolerance = 2.0);
    bool isPointOnCircle(const Point2D& point, const Circle& circle, double tolerance = 2.0);
    
    // Parameters for detection algorithms
    double cornerQualityLevel;
    int cornerMinDistance;
    int cornerBlockSize;
    int cornerKSize;
    double cornerK;
    
    double lineRho;
    double lineTheta;
    int lineThreshold;
    double lineMinLineLength;
    double lineMaxLineGap;
    
    double circleDp;
    double circleMinDist;
    double circleParam1;
    double circleParam2;
    int circleMinRadius;
    int circleMaxRadius;
};

// C-style interface for FFI
extern "C" {
    // Initialize corner detector
    CornerDetector* createCornerDetector();
    
    // Process image and return geometric primitives
    GeometricPrimitives* processImageFFI(CornerDetector* detector,
                                       const uint8_t* imageData,
                                       int width, int height, int channels);
    
    // Get number of lines
    int getLineCount(const GeometricPrimitives* primitives);
    
    // Get line at index
    Line getLine(const GeometricPrimitives* primitives, int index);
    
    // Get number of arcs
    int getArcCount(const GeometricPrimitives* primitives);
    
    // Get arc at index
    Arc getArc(const GeometricPrimitives* primitives, int index);
    
    // Get number of circles
    int getCircleCount(const GeometricPrimitives* primitives);
    
    // Get circle at index
    Circle getCircle(const GeometricPrimitives* primitives, int index);
    
    // Cleanup
    void destroyGeometricPrimitives(GeometricPrimitives* primitives);
    void destroyCornerDetector(CornerDetector* detector);
}

#endif // CORNER_DETECTOR_H


