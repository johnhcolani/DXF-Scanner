#include "corner_detector.h"
#include <opencv2/opencv.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/imgcodecs.hpp>
#include <algorithm>
#include <cmath>

CornerDetector::CornerDetector() {
    // Initialize parameters for corner detection
    cornerQualityLevel = 0.01;
    cornerMinDistance = 10;
    cornerBlockSize = 3;
    cornerKSize = 3;
    cornerK = 0.04;
    
    // Initialize parameters for line detection
    lineRho = 1.0;
    lineTheta = CV_PI / 180.0;
    lineThreshold = 50;
    lineMinLineLength = 30;
    lineMaxLineGap = 10;
    
    // Initialize parameters for circle detection
    circleDp = 1.0;
    circleMinDist = 30;
    circleParam1 = 50;
    circleParam2 = 30;
    circleMinRadius = 5;
    circleMaxRadius = 100;
}

CornerDetector::~CornerDetector() {
    // Destructor
}

cv::Mat CornerDetector::imageDataToMat(const std::vector<uint8_t>& imageData, 
                                      int width, int height, int channels) {
    if (channels == 1) {
        return cv::Mat(height, width, CV_8UC1, const_cast<uint8_t*>(imageData.data()));
    } else if (channels == 3) {
        return cv::Mat(height, width, CV_8UC3, const_cast<uint8_t*>(imageData.data()));
    } else if (channels == 4) {
        return cv::Mat(height, width, CV_8UC4, const_cast<uint8_t*>(imageData.data()));
    }
    return cv::Mat();
}

std::vector<uint8_t> CornerDetector::matToImageData(const cv::Mat& mat) {
    std::vector<uint8_t> data;
    if (mat.isContinuous()) {
        data.assign(mat.data, mat.data + mat.total() * mat.elemSize());
    } else {
        for (int i = 0; i < mat.rows; ++i) {
            data.insert(data.end(), mat.ptr<uint8_t>(i), mat.ptr<uint8_t>(i) + mat.cols * mat.channels());
        }
    }
    return data;
}

std::vector<Point2D> CornerDetector::detectCorners(const cv::Mat& image) {
    std::vector<Point2D> corners;
    
    // Convert to grayscale if needed
    cv::Mat gray;
    if (image.channels() > 1) {
        cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    } else {
        gray = image.clone();
    }
    
    // Apply Gaussian blur to reduce noise
    cv::Mat blurred;
    cv::GaussianBlur(gray, blurred, cv::Size(5, 5), 0);
    
    // Detect corners using Harris corner detector
    cv::Mat cornerResponse;
    cv::cornerHarris(blurred, cornerResponse, cornerBlockSize, cornerKSize, cornerK);
    
    // Normalize corner response
    cv::Mat normalized;
    cv::normalize(cornerResponse, normalized, 0, 255, cv::NORM_MINMAX, CV_8UC1);
    
    // Find corner points
    std::vector<cv::Point2f> cvCorners;
    cv::goodFeaturesToTrack(normalized, cvCorners, 100, cornerQualityLevel, cornerMinDistance);
    
    // Convert to our Point2D format
    for (const auto& corner : cvCorners) {
        corners.push_back({corner.x, corner.y});
    }
    
    return corners;
}

std::vector<Line> CornerDetector::detectLines(const cv::Mat& image, const std::vector<Point2D>& corners) {
    std::vector<Line> lines;
    
    // Convert to grayscale if needed
    cv::Mat gray;
    if (image.channels() > 1) {
        cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    } else {
        gray = image.clone();
    }
    
    // Apply Canny edge detection
    cv::Mat edges;
    cv::Canny(gray, edges, 50, 150);
    
    // Detect lines using Hough transform
    std::vector<cv::Vec4i> cvLines;
    cv::HoughLinesP(edges, cvLines, lineRho, lineTheta, lineThreshold, 
                    lineMinLineLength, lineMaxLineGap);
    
    // Convert to our Line format
    for (const auto& cvLine : cvLines) {
        Line line;
        line.start = {static_cast<double>(cvLine[0]), static_cast<double>(cvLine[1])};
        line.end = {static_cast<double>(cvLine[2]), static_cast<double>(cvLine[3])};
        lines.push_back(line);
    }
    
    return lines;
}

std::vector<Circle> CornerDetector::detectCircles(const cv::Mat& image) {
    std::vector<Circle> circles;
    
    // Convert to grayscale if needed
    cv::Mat gray;
    if (image.channels() > 1) {
        cv::cvtColor(image, gray, cv::COLOR_BGR2GRAY);
    } else {
        gray = image.clone();
    }
    
    // Apply Gaussian blur
    cv::Mat blurred;
    cv::GaussianBlur(gray, blurred, cv::Size(9, 9), 2, 2);
    
    // Detect circles using HoughCircles
    std::vector<cv::Vec3f> cvCircles;
    cv::HoughCircles(blurred, cvCircles, cv::HOUGH_GRADIENT, circleDp, circleMinDist,
                     circleParam1, circleParam2, circleMinRadius, circleMaxRadius);
    
    // Convert to our Circle format
    for (const auto& cvCircle : cvCircles) {
        Circle circle;
        circle.center = {cvCircle[0], cvCircle[1]};
        circle.radius = cvCircle[2];
        circles.push_back(circle);
    }
    
    return circles;
}

std::vector<Arc> CornerDetector::detectArcs(const cv::Mat& image, const std::vector<Point2D>& corners) {
    std::vector<Arc> arcs;
    
    // For now, we'll implement a simple arc detection based on corner analysis
    // This is a simplified approach - in practice, you might want to use more sophisticated methods
    
    if (corners.size() < 3) {
        return arcs;
    }
    
    // Group corners that might form arcs
    for (size_t i = 0; i < corners.size() - 2; ++i) {
        for (size_t j = i + 1; j < corners.size() - 1; ++j) {
            for (size_t k = j + 1; k < corners.size(); ++k) {
                Point2D p1 = corners[i];
                Point2D p2 = corners[j];
                Point2D p3 = corners[k];
                
                // Calculate angles to determine if points form an arc
                double angle1 = calculateAngle(p1, p2, p3);
                double angle2 = calculateAngle(p2, p3, p1);
                double angle3 = calculateAngle(p3, p1, p2);
                
                // If angles are reasonable for an arc (not too acute or obtuse)
                if (angle1 > 30 && angle1 < 150 && 
                    angle2 > 30 && angle2 < 150 && 
                    angle3 > 30 && angle3 < 150) {
                    
                    // Calculate circle center and radius
                    double x1 = p1.x, y1 = p1.y;
                    double x2 = p2.x, y2 = p2.y;
                    double x3 = p3.x, y3 = p3.y;
                    
                    double A = x1 * (y2 - y3) - y1 * (x2 - x3) + x2 * y3 - x3 * y2;
                    double B = (x1 * x1 + y1 * y1) * (y3 - y2) + (x2 * x2 + y2 * y2) * (y1 - y3) + (x3 * x3 + y3 * y3) * (y2 - y1);
                    double C = (x1 * x1 + y1 * y1) * (x2 - x3) + (x2 * x2 + y2 * y2) * (x3 - x1) + (x3 * x3 + y3 * y3) * (x1 - x2);
                    
                    if (std::abs(A) > 1e-6) {
                        double centerX = -B / (2 * A);
                        double centerY = -C / (2 * A);
                        double radius = std::sqrt((x1 - centerX) * (x1 - centerX) + (y1 - centerY) * (y1 - centerY));
                        
                        // Create arc
                        Arc arc;
                        arc.center = {centerX, centerY};
                        arc.radius = radius;
                        arc.startAngle = std::atan2(y1 - centerY, x1 - centerX);
                        arc.endAngle = std::atan2(y3 - centerY, x3 - centerX);
                        
                        arcs.push_back(arc);
                    }
                }
            }
        }
    }
    
    return arcs;
}

GeometricPrimitives CornerDetector::processImage(const std::vector<uint8_t>& imageData, 
                                                int width, int height, int channels) {
    GeometricPrimitives primitives;
    
    // Convert image data to OpenCV Mat
    cv::Mat image = imageDataToMat(imageData, width, height, channels);
    
    if (image.empty()) {
        return primitives;
    }
    
    // Detect corners
    std::vector<Point2D> corners = detectCorners(image);
    
    // Detect lines
    primitives.lines = detectLines(image, corners);
    
    // Detect circles
    primitives.circles = detectCircles(image);
    
    // Detect arcs
    primitives.arcs = detectArcs(image, corners);
    
    return primitives;
}

// Helper functions
double CornerDetector::calculateDistance(const Point2D& p1, const Point2D& p2) {
    double dx = p2.x - p1.x;
    double dy = p2.y - p1.y;
    return std::sqrt(dx * dx + dy * dy);
}

double CornerDetector::calculateAngle(const Point2D& p1, const Point2D& p2, const Point2D& p3) {
    double a = calculateDistance(p2, p3);
    double b = calculateDistance(p1, p3);
    double c = calculateDistance(p1, p2);
    
    if (a == 0 || b == 0 || c == 0) return 0;
    
    double cosA = (b * b + c * c - a * a) / (2 * b * c);
    cosA = std::max(-1.0, std::min(1.0, cosA)); // Clamp to [-1, 1]
    
    return std::acos(cosA) * 180.0 / CV_PI;
}

bool CornerDetector::isPointOnLine(const Point2D& point, const Line& line, double tolerance) {
    double distance = std::abs((line.end.y - line.start.y) * point.x - 
                              (line.end.x - line.start.x) * point.y + 
                              line.end.x * line.start.y - line.end.y * line.start.x) /
                     std::sqrt(std::pow(line.end.y - line.start.y, 2) + 
                              std::pow(line.end.x - line.start.x, 2));
    return distance <= tolerance;
}

bool CornerDetector::isPointOnCircle(const Point2D& point, const Circle& circle, double tolerance) {
    double distance = std::sqrt(std::pow(point.x - circle.center.x, 2) + 
                               std::pow(point.y - circle.center.y, 2));
    return std::abs(distance - circle.radius) <= tolerance;
}

// C-style interface implementation
extern "C" {
    CornerDetector* createCornerDetector() {
        return new CornerDetector();
    }
    
    GeometricPrimitives* processImageFFI(CornerDetector* detector,
                                       const uint8_t* imageData,
                                       int width, int height, int channels) {
        std::vector<uint8_t> data(imageData, imageData + width * height * channels);
        GeometricPrimitives* result = new GeometricPrimitives();
        *result = detector->processImage(data, width, height, channels);
        return result;
    }
    
    int getLineCount(const GeometricPrimitives* primitives) {
        return static_cast<int>(primitives->lines.size());
    }
    
    Line getLine(const GeometricPrimitives* primitives, int index) {
        return primitives->lines[index];
    }
    
    int getArcCount(const GeometricPrimitives* primitives) {
        return static_cast<int>(primitives->arcs.size());
    }
    
    Arc getArc(const GeometricPrimitives* primitives, int index) {
        return primitives->arcs[index];
    }
    
    int getCircleCount(const GeometricPrimitives* primitives) {
        return static_cast<int>(primitives->circles.size());
    }
    
    Circle getCircle(const GeometricPrimitives* primitives, int index) {
        return primitives->circles[index];
    }
    
    void destroyGeometricPrimitives(GeometricPrimitives* primitives) {
        delete primitives;
    }
    
    void destroyCornerDetector(CornerDetector* detector) {
        delete detector;
    }
}


