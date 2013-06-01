#import "RFViewFramebuffer.h"
#import "RFTextureFramebuffer.h"
#import "RFiOS5TextureFramebuffer.h"
#import "TKAlertCenter.h"
#import "MyRenderer.h"

static unsigned char vintage_lookup_table [] = {0, 0, 1, 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 11, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 15, 15, 15, 16, 16, 17, 17, 18, 19, 19, 20, 20, 21, 22, 23, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 38, 39, 40, 42, 43, 45, 46, 48, 49, 51, 53, 54, 56, 58, 60, 61, 63, 65, 67, 69, 71, 73, 76, 78, 80, 82, 84, 86, 89, 91, 93, 96, 98, 100, 103, 105, 107, 110, 112, 114, 117, 119, 121, 124, 126, 129, 131, 133, 136, 138, 140, 142, 145, 147, 149, 151, 153, 156, 158, 160, 162, 164, 166, 168, 170, 172, 174, 176, 177, 179, 181, 183, 185, 186, 188, 189, 191, 193, 194, 196, 197, 199, 200, 201, 203, 204, 205, 207, 208, 209, 210, 211, 212, 214, 215, 216, 217, 218, 219, 220, 221, 222, 223, 223, 224, 225, 226, 227, 228, 228, 229, 230, 231, 231, 232, 233, 234, 234, 235, 236, 236, 237, 238, 238, 239, 239, 240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246, 247, 247, 248, 248, 249, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 0, 0, 1, 2, 3, 4, 5, 6, 7, 8, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 55, 56, 57, 58, 59, 60, 61, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 76, 77, 78, 79, 81, 82, 83, 84, 86, 87, 88, 89, 91, 92, 93, 95, 96, 97, 98, 100, 101, 102, 104, 105, 106, 108, 109, 110, 112, 113, 114, 116, 117, 118, 120, 121, 122, 124, 125, 126, 128, 129, 130, 132, 133, 134, 136, 137, 138, 139, 141, 142, 143, 145, 146, 147, 149, 150, 151, 152, 154, 155, 156, 157, 159, 160, 161, 162, 164, 165, 166, 167, 168, 170, 171, 172, 173, 174, 175, 177, 178, 179, 180, 181, 182, 183, 184, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 207, 208, 209, 210, 211, 212, 213, 214, 214, 215, 216, 217, 218, 218, 219, 220, 221, 222, 222, 223, 224, 225, 225, 226, 227, 227, 228, 229, 230, 230, 231, 232, 232, 233, 234, 234, 235, 235, 236, 237, 237, 238, 239, 239, 240, 240, 241, 241, 242, 243, 243, 244, 244, 245, 245, 246, 247, 247, 248, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 255, 53, 53, 53, 54, 54, 55, 55, 55, 56, 56, 57, 57, 57, 58, 58, 59, 59, 59, 60, 60, 61, 61, 62, 62, 62, 63, 63, 64, 64, 65, 65, 65, 66, 66, 67, 67, 68, 68, 69, 69, 70, 70, 71, 71, 72, 72, 73, 73, 74, 74, 75, 75, 76, 76, 77, 77, 78, 78, 79, 79, 80, 81, 81, 82, 82, 83, 83, 84, 85, 85, 86, 86, 87, 88, 88, 89, 89, 90, 91, 91, 92, 93, 93, 94, 95, 95, 96, 97, 97, 98, 99, 99, 100, 101, 101, 102, 103, 103, 104, 105, 105, 106, 107, 108, 108, 109, 110, 110, 111, 112, 113, 113, 114, 115, 116, 116, 117, 118, 118, 119, 120, 121, 121, 122, 123, 124, 124, 125, 126, 127, 127, 128, 129, 130, 130, 131, 132, 133, 133, 134, 135, 135, 136, 137, 138, 138, 139, 140, 141, 141, 142, 143, 143, 144, 145, 146, 146, 147, 148, 148, 149, 150, 150, 151, 152, 152, 153, 154, 154, 155, 156, 156, 157, 158, 158, 159, 160, 160, 161, 162, 162, 163, 163, 164, 165, 165, 166, 166, 167, 168, 168, 169, 169, 170, 170, 171, 172, 172, 173, 173, 174, 174, 175, 175, 176, 176, 177, 177, 178, 178, 179, 179, 180, 180, 181, 181, 182, 182, 183, 183, 184, 184, 185, 185, 186, 186, 186, 187, 187, 188, 188, 189, 189, 189, 190, 190, 191, 191, 192, 192, 192, 193, 193, 194, 194, 194, 195, 195, 196, 196, 196, 197, 197, 198, 198, 199};

static unsigned char red_green_table [] = {0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15, 15, 16, 17, 18, 18, 19, 20, 21, 21, 22, 23, 24, 25, 25, 26, 27, 28, 29, 29, 30, 31, 32, 33, 34, 35, 36, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 78, 79, 80, 81, 82, 83, 85, 86, 87, 88, 90, 91, 92, 93, 94, 96, 97, 98, 99, 101, 102, 103, 104, 106, 107, 108, 110, 111, 112, 113, 115, 116, 117, 119, 120, 121, 122, 124, 125, 126, 128, 129, 130, 132, 133, 134, 135, 137, 138, 139, 141, 142, 143, 144, 146, 147, 148, 150, 151, 152, 153, 155, 156, 157, 158, 160, 161, 162, 163, 164, 166, 167, 168, 169, 171, 172, 173, 174, 175, 176, 178, 179, 180, 181, 182, 183, 184, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 218, 219, 220, 221, 222, 223, 224, 225, 225, 226, 227, 228, 229, 229, 230, 231, 232, 233, 233, 234, 235, 236, 236, 237, 238, 239, 239, 240, 241, 242, 242, 243, 244, 245, 245, 246, 247, 247, 248, 249, 250, 250, 251, 252, 252, 253, 254, 255, 0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15, 15, 16, 17, 18, 18, 19, 20, 21, 21, 22, 23, 24, 25, 25, 26, 27, 28, 29, 29, 30, 31, 32, 33, 34, 35, 36, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 78, 79, 80, 81, 82, 83, 85, 86, 87, 88, 90, 91, 92, 93, 94, 96, 97, 98, 99, 101, 102, 103, 104, 106, 107, 108, 110, 111, 112, 113, 115, 116, 117, 119, 120, 121, 122, 124, 125, 126, 128, 129, 130, 132, 133, 134, 135, 137, 138, 139, 141, 142, 143, 144, 146, 147, 148, 150, 151, 152, 153, 155, 156, 157, 158, 160, 161, 162, 163, 164, 166, 167, 168, 169, 171, 172, 173, 174, 175, 176, 178, 179, 180, 181, 182, 183, 184, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 218, 219, 220, 221, 222, 223, 224, 225, 225, 226, 227, 228, 229, 229, 230, 231, 232, 233, 233, 234, 235, 236, 236, 237, 238, 239, 239, 240, 241, 242, 242, 243, 244, 245, 245, 246, 247, 247, 248, 249, 250, 250, 251, 252, 252, 253, 254, 255, 0, 0, 1, 2, 2, 3, 4, 4, 5, 6, 7, 7, 8, 9, 9, 10, 11, 12, 12, 13, 14, 15, 15, 16, 17, 18, 18, 19, 20, 21, 21, 22, 23, 24, 25, 25, 26, 27, 28, 29, 29, 30, 31, 32, 33, 34, 35, 36, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 74, 75, 76, 78, 79, 80, 81, 82, 83, 85, 86, 87, 88, 90, 91, 92, 93, 94, 96, 97, 98, 99, 101, 102, 103, 104, 106, 107, 108, 110, 111, 112, 113, 115, 116, 117, 119, 120, 121, 122, 124, 125, 126, 128, 129, 130, 132, 133, 134, 135, 137, 138, 139, 141, 142, 143, 144, 146, 147, 148, 150, 151, 152, 153, 155, 156, 157, 158, 160, 161, 162, 163, 164, 166, 167, 168, 169, 171, 172, 173, 174, 175, 176, 178, 179, 180, 181, 182, 183, 184, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 218, 219, 220, 221, 222, 223, 224, 225, 225, 226, 227, 228, 229, 229, 230, 231, 232, 233, 233, 234, 235, 236, 236, 237, 238, 239, 239, 240, 241, 242, 242, 243, 244, 245, 245, 246, 247, 247, 248, 249, 250, 250, 251, 252, 252, 253, 254, 255};

static unsigned char nashville_table [] = {0, 0, 0, 0, 0, 0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 10, 11, 11, 12, 12, 12, 13, 13, 13, 14, 14, 14, 15, 15, 15, 16, 16, 17, 18, 18, 19, 20, 21, 21, 22, 23, 23, 23, 24, 24, 24, 24, 24, 25, 25, 25, 26, 26, 27, 27, 28, 30, 31, 33, 36, 39, 43, 47, 52, 56, 61, 66, 70, 74, 78, 81, 84, 86, 89, 91, 93, 95, 97, 99, 101, 103, 105, 107, 108, 110, 112, 114, 116, 118, 119, 121, 123, 124, 126, 127, 129, 130, 132, 133, 135, 136, 138, 139, 140, 142, 143, 144, 146, 147, 148, 150, 151, 152, 154, 155, 156, 157, 159, 160, 161, 163, 164, 165, 166, 168, 169, 170, 171, 173, 174, 175, 176, 177, 179, 180, 181, 182, 183, 185, 186, 187, 188, 189, 190, 191, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 219, 220, 221, 222, 223, 223, 224, 225, 226, 226, 227, 228, 228, 229, 230, 230, 231, 232, 232, 233, 234, 234, 235, 235, 236, 236, 237, 238, 238, 239, 239, 240, 240, 241, 241, 242, 242, 243, 243, 243, 244, 244, 245, 245, 246, 246, 246, 247, 247, 248, 248, 248, 249, 249, 250, 250, 250, 251, 251, 251, 252, 252, 252, 253, 253, 254, 254, 254, 255, 255, 255, 255, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 5, 5, 6, 7, 7, 8, 9, 10, 12, 13, 15, 17, 19, 21, 23, 25, 28, 30, 33, 35, 38, 40, 42, 44, 46, 48, 50, 52, 54, 55, 57, 58, 60, 61, 63, 64, 65, 67, 68, 69, 71, 72, 73, 74, 75, 77, 78, 79, 80, 82, 83, 84, 85, 86, 88, 89, 90, 91, 92, 94, 95, 96, 97, 98, 99, 100, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 173, 174, 175, 176, 177, 177, 178, 179, 180, 180, 181, 182, 183, 183, 184, 185, 186, 186, 187, 188, 189, 189, 190, 191, 192, 192, 193, 194, 195, 195, 196, 197, 198, 198, 199, 200, 201, 201, 202, 203, 204, 204, 205, 206, 207, 207, 208, 209, 209, 210, 211, 211, 212, 213, 213, 214, 215, 215, 216, 216, 217, 217, 218, 218, 219, 219, 220, 220, 221, 221, 222, 222, 223, 223, 223, 224, 224, 224, 225, 225, 226, 226, 226, 227, 227, 227, 228, 228, 228, 229, 229, 229, 230, 230, 230, 230, 230, 230, 230, 230, 230, 65, 65, 66, 66, 67, 67, 68, 68, 69, 69, 70, 70, 71, 71, 72, 72, 73, 73, 74, 74, 75, 75, 76, 76, 77, 77, 78, 79, 79, 80, 80, 81, 82, 82, 83, 84, 84, 85, 86, 86, 87, 88, 88, 89, 90, 91, 91, 92, 93, 93, 94, 95, 96, 96, 97, 98, 99, 99, 100, 101, 101, 102, 103, 104, 104, 105, 106, 106, 107, 108, 108, 109, 110, 110, 111, 112, 112, 113, 114, 114, 115, 116, 116, 117, 118, 118, 119, 120, 120, 121, 121, 122, 123, 123, 124, 125, 125, 126, 126, 127, 128, 128, 129, 129, 130, 131, 131, 132, 132, 133, 134, 134, 135, 135, 136, 137, 137, 138, 138, 139, 139, 140, 141, 141, 142, 142, 143, 144, 144, 145, 145, 146, 146, 147, 148, 148, 149, 149, 150, 150, 151, 152, 152, 153, 153, 154, 154, 155, 156, 156, 157, 157, 158, 158, 159, 160, 160, 161, 161, 162, 162, 163, 164, 164, 165, 165, 166, 166, 167, 167, 168, 169, 169, 170, 170, 171, 171, 172, 172, 173, 173, 174, 175, 175, 176, 176, 177, 177, 178, 178, 179, 179, 180, 180, 181, 181, 182, 182, 182, 183, 183, 184, 184, 185, 185, 186, 186, 186, 187, 187, 188, 188, 189, 189, 189, 190, 190, 191, 191, 191, 192, 192, 193, 193, 193, 194, 194, 194, 195, 195, 196, 196, 196, 197, 197, 198, 198, 198, 199, 199, 199, 200, 200, 201, 201, 201, 202, 202, 202, 203, 203, 204, 204, 204, 205, 205};

static unsigned char _1977_table [] = {82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 82, 81, 81, 81, 81, 81, 81, 81, 81, 81, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 80, 81, 81, 81, 82, 82, 83, 84, 84, 85, 86, 87, 88, 89, 91, 92, 93, 95, 96, 98, 99, 101, 102, 104, 105, 106, 108, 109, 110, 112, 113, 114, 115, 117, 118, 119, 120, 121, 123, 124, 125, 126, 127, 128, 130, 131, 132, 133, 134, 136, 137, 138, 139, 140, 141, 142, 144, 145, 146, 147, 148, 149, 150, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 211, 212, 213, 214, 215, 216, 217, 218, 219, 220, 221, 222, 222, 223, 224, 224, 225, 225, 225, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 225, 225, 225, 225, 225, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 225, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 224, 225, 225, 225, 225, 225, 225, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 226, 56, 56, 56, 57, 57, 57, 57, 57, 57, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 58, 57, 57, 57, 57, 57, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 56, 57, 57, 58, 58, 58, 59, 60, 60, 61, 62, 63, 64, 65, 66, 67, 68, 70, 71, 72, 73, 75, 76, 77, 79, 80, 81, 83, 84, 85, 86, 87, 89, 90, 91, 92, 93, 94, 95, 96, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116, 117, 119, 120, 121, 122, 123, 124, 125, 126, 127, 128, 129, 130, 131, 132, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 162, 163, 164, 165, 166, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 186, 186, 187, 188, 189, 190, 191, 192, 193, 194, 194, 195, 196, 197, 198, 199, 200, 200, 201, 202, 203, 204, 205, 206, 206, 207, 208, 209, 210, 211, 211, 212, 213, 214, 215, 216, 216, 217, 218, 219, 220, 220, 221, 222, 223, 224, 225, 225, 226, 227, 228, 229, 229, 230, 231, 232, 233, 233, 234, 235, 236, 237, 237, 238, 239, 240, 241, 241, 242, 243, 244, 245, 245, 246, 247, 248, 248, 249, 250, 251, 252, 252, 253, 254, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 65, 64, 64, 64, 64, 64, 64, 64, 64, 64, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 63, 64, 64, 65, 65, 66, 67, 68, 69, 71, 72, 74, 75, 77, 78, 80, 81, 83, 84, 86, 87, 89, 90, 91, 92, 93, 95, 96, 97, 98, 99, 100, 102, 103, 104, 105, 107, 108, 109, 110, 112, 113, 114, 116, 117, 118, 119, 121, 122, 123, 124, 126, 127, 128, 129, 130, 132, 133, 134, 135, 136, 138, 139, 140, 141, 142, 143, 144, 146, 147, 148, 149, 150, 151, 152, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 178, 179, 180, 181, 182, 184, 185, 186, 187, 189, 190, 191, 192, 193, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 205, 206, 207, 208, 208, 209, 209, 210, 210, 211, 211, 211, 212, 212, 212, 213, 213, 213, 213, 213, 213, 213, 214, 214, 214, 214, 214, 214, 214, 214, 214, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 213, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 212, 213, 213, 213, 213, 213, 213, 213};

static unsigned char lord_kelvin_table [] = {43, 45, 47, 49, 51, 53, 54, 56, 58, 60, 62, 64, 66, 68, 70, 72, 73, 75, 77, 79, 81, 83, 85, 86, 88, 90, 92, 94, 96, 97, 99, 101, 103, 104, 106, 108, 110, 111, 113, 115, 117, 118, 120, 122, 123, 125, 127, 128, 130, 131, 133, 134, 136, 138, 139, 141, 142, 144, 145, 146, 148, 149, 151, 152, 153, 155, 156, 158, 159, 160, 161, 163, 164, 165, 167, 168, 169, 170, 171, 173, 174, 175, 176, 177, 178, 179, 180, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 197, 198, 199, 200, 201, 202, 203, 204, 204, 205, 206, 207, 208, 208, 209, 210, 211, 211, 212, 213, 214, 214, 215, 216, 216, 217, 218, 218, 219, 220, 220, 221, 221, 222, 223, 223, 224, 224, 225, 226, 226, 227, 227, 228, 228, 229, 229, 230, 230, 231, 231, 232, 232, 233, 233, 233, 234, 234, 235, 235, 236, 236, 236, 237, 237, 237, 238, 238, 239, 239, 239, 240, 240, 240, 241, 241, 241, 242, 242, 242, 242, 243, 243, 243, 244, 244, 244, 244, 245, 245, 245, 245, 246, 246, 246, 246, 247, 247, 247, 247, 247, 248, 248, 248, 248, 248, 249, 249, 249, 249, 249, 249, 250, 250, 250, 250, 250, 250, 251, 251, 251, 251, 251, 251, 252, 252, 252, 252, 252, 252, 252, 252, 253, 253, 253, 253, 253, 253, 253, 253, 254, 254, 254, 254, 254, 254, 254, 254, 255, 255, 255, 255, 255, 27, 28, 29, 30, 32, 33, 34, 35, 36, 37, 38, 39, 40, 42, 43, 44, 45, 46, 47, 48, 49, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 112, 113, 114, 115, 116, 117, 118, 119, 120, 121, 122, 123, 123, 124, 125, 126, 127, 128, 129, 130, 131, 131, 132, 133, 134, 135, 136, 137, 138, 138, 139, 140, 141, 142, 143, 144, 144, 145, 146, 147, 148, 149, 149, 150, 151, 152, 153, 153, 154, 155, 156, 157, 158, 158, 159, 160, 161, 162, 162, 163, 164, 165, 166, 166, 167, 168, 169, 169, 170, 171, 172, 173, 173, 174, 175, 176, 176, 177, 178, 179, 180, 180, 181, 182, 183, 183, 184, 185, 186, 186, 187, 188, 189, 189, 190, 191, 192, 192, 193, 194, 195, 195, 196, 197, 198, 198, 199, 200, 201, 201, 202, 203, 204, 204, 205, 206, 207, 207, 208, 209, 209, 210, 211, 212, 212, 213, 214, 215, 215, 216, 217, 218, 218, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 219, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 86, 87, 87, 87, 87, 87, 87, 87, 87, 87, 87, 87, 87, 87, 87, 88, 88, 88, 88, 88, 88, 88, 88, 88, 89, 89, 89, 89, 89, 89, 90, 90, 90, 90, 90, 91, 91, 91, 91, 92, 92, 92, 93, 93, 93, 93, 94, 94, 94, 95, 95, 96, 96, 96, 97, 97, 98, 98, 99, 99, 99, 100, 101, 101, 102, 102, 103, 103, 104, 104, 105, 106, 106, 107, 108, 108, 109, 110, 110, 111, 112, 113, 113, 114, 115, 116, 116, 117, 118, 119, 119, 120, 121, 122, 123, 124, 125, 125, 126, 127, 128, 129, 130, 131, 132, 133, 133, 134, 135, 136, 137, 138, 139, 140, 141, 142, 143, 144, 145, 146, 147, 148, 149, 150, 151, 152, 153, 154, 155, 156, 157, 158, 159, 160, 161, 162, 163, 164, 165, 166, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167, 167};

static unsigned char amatorke_table [] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 2, 2, 3, 3, 3, 4, 4, 5, 5, 6, 7, 7, 8, 9, 10, 11, 11, 12, 12, 13, 15, 16, 17, 18, 19, 20, 21, 22, 24, 26, 27, 28, 30, 30, 32, 33, 35, 36, 38, 38, 40, 41, 43, 43, 45, 46, 47, 48, 49, 51, 52, 53, 54, 55, 56, 57, 57, 60, 64, 64, 67, 69, 72, 74, 76, 79, 81, 83, 86, 88, 91, 92, 96, 97, 101, 103, 105, 107, 111, 113, 116, 117, 119, 123, 124, 129, 130, 132, 136, 137, 139, 142, 144, 145, 147, 151, 153, 153, 156, 158, 161, 162, 164, 166, 169, 171, 172, 174, 175, 178, 181, 182, 183, 184, 187, 189, 189, 191, 193, 194, 196, 198, 199, 201, 202, 204, 205, 206, 206, 208, 209, 211, 212, 214, 214, 215, 216, 217, 217, 219, 220, 220, 222, 224, 224, 225, 227, 227, 228, 230, 230, 231, 231, 232, 232, 233, 233, 235, 235, 236, 236, 238, 238, 240, 240, 241, 241, 243, 243, 243, 244, 244, 246, 246, 247, 247, 247, 247, 249, 249, 250, 250, 250, 252, 252, 252, 253, 253, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 8, 9, 9, 10, 10, 11, 11, 12, 13, 14, 15, 15, 18, 20, 21, 24, 25, 27, 30, 31, 34, 36, 37, 40, 41, 44, 45, 48, 50, 52, 54, 57, 58, 61, 62, 65, 68, 69, 72, 73, 76, 77, 80, 83, 84, 87, 89, 90, 93, 94, 97, 100, 101, 103, 106, 107, 110, 111, 113, 116, 117, 120, 122, 123, 126, 127, 129, 131, 132, 134, 135, 137, 139, 140, 142, 143, 145, 147, 148, 150, 151, 153, 154, 156, 157, 159, 161, 162, 164, 165, 167, 168, 170, 171, 172, 174, 175, 177, 178, 180, 181, 182, 184, 185, 186, 188, 189, 190, 192, 193, 194, 196, 197, 198, 199, 201, 202, 203, 204, 205, 206, 208, 209, 210, 211, 212, 213, 214, 216, 217, 218, 219, 220, 221, 222, 222, 223, 224, 225, 226, 227, 227, 228, 229, 230, 230, 231, 232, 232, 233, 234, 234, 235, 236, 236, 237, 238, 238, 239, 239, 240, 240, 241, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246, 247, 247, 247, 248, 248, 249, 249, 250, 250, 250, 251, 251, 252, 252, 252, 253, 253, 253, 254, 254, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 2, 2, 2, 3, 3, 3, 3, 4, 4, 5, 5, 6, 7, 7, 8, 9, 10, 10, 11, 11, 13, 14, 15, 15, 17, 17, 18, 20, 20, 21, 23, 24, 25, 26, 27, 29, 30, 32, 33, 35, 35, 36, 38, 40, 42, 42, 43, 45, 47, 47, 49, 51, 51, 53, 55, 55, 57, 57, 59, 61, 61, 64, 64, 66, 66, 68, 72, 72, 76, 76, 77, 77, 77, 81, 81, 83, 83, 86, 86, 90, 90, 90, 92, 92, 95, 95, 95, 99, 99, 101, 101, 101, 104, 104, 106, 106, 106, 109, 109, 109, 112, 112, 112, 114, 114, 117, 117, 117, 120, 120, 122, 122, 122, 125, 125, 125, 127, 127, 129, 129, 131, 131, 131, 132, 132, 134, 134, 135, 135, 137, 137, 139, 139, 140, 140, 142, 142, 143, 143, 145, 145, 147, 147, 148, 150, 150, 151, 153, 153, 154, 156, 156, 157, 159, 159, 161, 162, 164, 165, 165, 167, 168, 170, 171, 172, 174, 174, 175, 177, 178, 180, 181, 182, 184, 185, 186, 189, 190, 192, 193, 194, 196, 198, 199, 201, 202, 204, 205, 206, 209, 210, 211, 213, 214, 216, 217, 219, 220, 222, 222, 224, 225, 227, 227, 229, 230, 231, 232, 234, 234, 236, 237, 238, 239, 240, 240, 241, 242, 243, 244, 245, 246, 247, 247, 248, 249, 250, 250, 251, 252, 252, 253, 253, 254, 255};

static unsigned char lomo_table [] = {0, 0, 1, 1, 2, 2, 3, 3, 4, 4, 5, 5, 6, 6, 7, 7, 8, 8, 9, 9, 10, 10, 11, 12, 12, 13, 13, 14, 14, 15, 15, 16, 17, 17, 18, 18, 19, 20, 20, 21, 22, 22, 23, 24, 24, 25, 26, 26, 27, 28, 29, 29, 30, 31, 32, 33, 33, 34, 35, 36, 37, 38, 39, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55, 56, 57, 58, 60, 61, 62, 63, 65, 66, 67, 68, 70, 71, 72, 74, 75, 77, 78, 79, 81, 82, 84, 85, 87, 88, 90, 91, 93, 94, 96, 97, 99, 100, 102, 103, 105, 106, 108, 110, 111, 113, 114, 116, 117, 119, 121, 122, 124, 125, 127, 129, 130, 132, 133, 135, 137, 138, 140, 141, 143, 145, 146, 148, 149, 151, 152, 154, 155, 157, 159, 160, 162, 163, 165, 166, 168, 169, 171, 172, 173, 175, 176, 178, 179, 181, 182, 183, 185, 186, 187, 189, 190, 191, 193, 194, 195, 196, 197, 199, 200, 201, 202, 203, 204, 205, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 216, 217, 218, 219, 220, 221, 222, 223, 223, 224, 225, 226, 227, 227, 228, 229, 230, 230, 231, 232, 232, 233, 234, 234, 235, 236, 236, 237, 237, 238, 239, 239, 240, 240, 241, 242, 242, 243, 243, 244, 244, 245, 245, 246, 247, 247, 248, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254, 255, 255, 0, 1, 1, 2, 2, 3, 3, 4, 5, 5, 6, 6, 7, 8, 8, 9, 9, 10, 10, 11, 12, 12, 13, 14, 14, 15, 15, 16, 17, 17, 18, 19, 19, 20, 21, 21, 22, 23, 24, 24, 25, 26, 27, 27, 28, 29, 30, 30, 31, 32, 33, 34, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 61, 62, 63, 64, 65, 67, 68, 69, 71, 72, 73, 74, 76, 77, 78, 80, 81, 83, 84, 85, 87, 88, 90, 91, 92, 94, 95, 97, 98, 100, 101, 103, 104, 105, 107, 108, 110, 111, 113, 114, 116, 117, 119, 120, 122, 123, 125, 126, 128, 129, 131, 133, 134, 136, 137, 139, 140, 142, 143, 145, 146, 147, 149, 150, 152, 153, 155, 156, 158, 159, 161, 162, 163, 165, 166, 168, 169, 170, 172, 173, 175, 176, 177, 179, 180, 181, 182, 184, 185, 186, 188, 189, 190, 191, 192, 194, 195, 196, 197, 198, 199, 200, 201, 202, 204, 205, 206, 207, 208, 209, 210, 210, 211, 212, 213, 214, 215, 216, 217, 218, 219, 219, 220, 221, 222, 223, 223, 224, 225, 226, 226, 227, 228, 229, 229, 230, 231, 231, 232, 233, 234, 234, 235, 235, 236, 237, 237, 238, 239, 239, 240, 240, 241, 242, 242, 243, 243, 244, 245, 245, 246, 246, 247, 247, 248, 249, 249, 250, 250, 251, 251, 252, 252, 253, 253, 254, 254, 255, 0, 2, 3, 5, 6, 8, 9, 11, 12, 14, 16, 17, 19, 20, 22, 23, 25, 26, 28, 29, 31, 32, 34, 35, 37, 38, 40, 41, 43, 44, 45, 47, 48, 50, 51, 52, 54, 55, 57, 58, 59, 61, 62, 63, 64, 66, 67, 68, 69, 70, 72, 73, 74, 75, 76, 77, 78, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 89, 90, 91, 92, 93, 94, 95, 96, 96, 97, 98, 99, 100, 100, 101, 102, 103, 104, 104, 105, 106, 106, 107, 108, 108, 109, 110, 110, 111, 112, 112, 113, 114, 114, 115, 115, 116, 117, 117, 118, 118, 119, 120, 120, 121, 121, 122, 122, 123, 123, 124, 125, 125, 126, 126, 127, 127, 128, 128, 129, 129, 130, 130, 131, 131, 132, 133, 133, 134, 134, 135, 135, 136, 136, 137, 137, 138, 138, 139, 140, 140, 141, 141, 142, 142, 143, 144, 144, 145, 145, 146, 147, 147, 148, 149, 149, 150, 151, 151, 152, 153, 153, 154, 155, 155, 156, 157, 158, 158, 159, 160, 161, 162, 162, 163, 164, 165, 166, 167, 167, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 187, 188, 189, 190, 191, 193, 194, 195, 196, 197, 199, 200, 201, 203, 204, 205, 206, 208, 209, 210, 212, 213, 215, 216, 217, 219, 220, 222, 223, 224, 226, 227, 229, 230, 232, 233, 234, 236, 237, 239, 240, 242, 243, 245, 246, 248, 249, 251, 252, 254, 255};

#if HD
    #define TARGET_TEXTURE_WIDTH 720
    #define TARGET_TEXTURE_HEIGHT 1280
#else
    #define TARGET_TEXTURE_WIDTH 445
    #define TARGET_TEXTURE_HEIGHT 640
#endif

#define CAPTURED_FRAME_TEXTURE 0
#define OUTPUT_TEXTURE_1 1
#define OUTPUT_TEXTURE_2 2
#define OUTPUT_TEXTURE_3 5
#define iOS5_FRAMEBUFFER_TEXTURE 3
#define LOOKUP_TEXTURE 4

MyRenderer::MyRenderer(RFGLView* previewView):RFRenderer(previewView)
{
    current_filter_index = 0;
    
    RFFramebuffer *view_fb            = new RFViewFramebuffer(previewView),
                  *iOS5_texture_fb    = new RFiOS5TextureFramebuffer(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT, iOS5_FRAMEBUFFER_TEXTURE),
                  *texture_fb_1       = new RFTextureFramebuffer(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT, OUTPUT_TEXTURE_1),
                  *texture_fb_2       = new RFTextureFramebuffer(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT, OUTPUT_TEXTURE_2),
                  *texture_fb_3       = new RFTextureFramebuffer(TARGET_TEXTURE_WIDTH, TARGET_TEXTURE_HEIGHT, OUTPUT_TEXTURE_3);
    
    framebuffers.push_back(view_fb);
    framebuffers.push_back(iOS5_texture_fb);
    framebuffers.push_back(texture_fb_1);
    framebuffers.push_back(texture_fb_2);
    framebuffers.push_back(texture_fb_3);
    
    map <string, RFFilterCollection*> corresp;

#if TARGET_IPHONE_SIMULATOR
    RFFilter *crop = new RFFilter("copy.vsh", "crop_simulator.fsh", FLIPPED_CROPPED);
#else
    RFFilter *crop = new RFFilter("copy.vsh", "crop.fsh", FLIPPED_CROPPED);
#endif
    crop->bind_uniform_to_int_value("input_texture", CAPTURED_FRAME_TEXTURE);
    crop->setup();
    
    RFFilter *copy = new RFFilter("copy.vsh", "copy.fsh", FLIPPED);
    copy->bind_uniform_to_int_value("input_texture", iOS5_FRAMEBUFFER_TEXTURE);
    copy->setup();
    
    // Normal Filter
    RFFilterCollection* normal = new RFFilterCollection("Normal");
    normal->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *copy2 = new RFFilter("copy.vsh", "copy.fsh", FLIPPED);
    copy2->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    copy2->setup();
    normal->add_filter_framebuffer_pair(copy2, iOS5_texture_fb);
    normal->add_filter_framebuffer_pair(copy, view_fb);
    corresp[normal->getName()] = normal;
        
    // Vintage Filter
    RFFilterCollection* vintage = new RFFilterCollection("Vintage");
    vintage->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_vintage = new RFTextureFilter("copy.vsh", "lookup_table.fsh", "vintage_lookup_table", vintage_lookup_table, 256, 3, FLIPPED);
    lookup_vintage->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_vintage->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_vintage->setup();
    vintage->add_filter_framebuffer_pair(lookup_vintage, texture_fb_2);
    RFFilter *multiply = new RFTextureFilter("copy.vsh", "color_burn.fsh", "sutroEdgeBurn.png", STRAIGHT);
    multiply->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_2);
    multiply->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    float screen_vec_vintage[4] = {0.89, 0.047, 0.66, 0.15};
    multiply->bind_uniform_to_vec4_value("screen_vec", screen_vec_vintage);
    multiply->setup();
    vintage->add_filter_framebuffer_pair(multiply, iOS5_texture_fb);
    vintage->add_filter_framebuffer_pair(copy, view_fb);
    corresp[vintage->getName()] = vintage;
    
    // Nashville Filter
    RFFilterCollection* nashville = new RFFilterCollection("Dusk");
    nashville->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_nashville = new RFTextureFilter("copy.vsh", "lookup_table.fsh", "nashville_lookup_table", nashville_table, 256, 3, FLIPPED);
    lookup_nashville->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_nashville->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_nashville->setup();
    nashville->add_filter_framebuffer_pair(lookup_nashville, iOS5_texture_fb);
    nashville->add_filter_framebuffer_pair(copy, view_fb);
    corresp[nashville->getName()] = nashville;
    
    // Lomo Filter
    RFFilterCollection* lomo = new RFFilterCollection("Lomo");
    lomo->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_lomo = new RFTextureFilter("copy.vsh", "lookup_table.fsh", "lomo_lookup_table", lomo_table, 256, 3, FLIPPED);
    lookup_lomo->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_lomo->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_lomo->setup();
    lomo->add_filter_framebuffer_pair(lookup_lomo, texture_fb_2);
    RFFilter *multiply_lomo = new RFTextureFilter("copy.vsh", "color_burn.fsh", "vignette.png", STRAIGHT);
    multiply_lomo->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_2);
    multiply_lomo->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    float screen_vec_lomo[4] = {0.0, 0.0, 0.0, 0.0};
    multiply_lomo->bind_uniform_to_vec4_value("screen_vec", screen_vec_lomo);
    multiply_lomo->setup();
    lomo->add_filter_framebuffer_pair(multiply_lomo, iOS5_texture_fb);
    lomo->add_filter_framebuffer_pair(copy, view_fb);
    corresp[lomo->getName()] = lomo;
    
    // 1977 Filter
    RFFilterCollection* _1977 = new RFFilterCollection("Aura");
    _1977->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_1977 = new RFTextureFilter("copy.vsh", "lookup_table.fsh", "1977_lookup_table", _1977_table, 256, 3, FLIPPED);
    lookup_1977->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_1977->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_1977->setup();
    _1977->add_filter_framebuffer_pair(lookup_1977, iOS5_texture_fb);
    _1977->add_filter_framebuffer_pair(copy, view_fb);
    corresp[_1977->getName()] = _1977;
    
    // Lord Kelvin Filter
    RFFilterCollection* lord_kelvin = new RFFilterCollection("Sahara");
    lord_kelvin->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_lord_kelvin = new RFTextureFilter("copy.vsh", "lookup_table_kelvin.fsh", "lord_kelvin_lookup_table", lord_kelvin_table, 256, 3, FLIPPED);
    lookup_lord_kelvin->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_lord_kelvin->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_lord_kelvin->setup();
    lord_kelvin->add_filter_framebuffer_pair(lookup_lord_kelvin, texture_fb_2);
    RFFilter *multiply_kelvin = new RFTextureFilter("copy.vsh", "color_burn.fsh", "soft_overlay.png", STRAIGHT);
    multiply_kelvin->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_2);
    multiply_kelvin->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    float screen_vec_kelvin[4] = {1.0, 0, 0, 0.15};
    multiply_kelvin->bind_uniform_to_vec4_value("screen_vec", screen_vec_kelvin);
    multiply_kelvin->setup();
    lord_kelvin->add_filter_framebuffer_pair(multiply_kelvin, iOS5_texture_fb);
    lord_kelvin->add_filter_framebuffer_pair(copy, view_fb);
    corresp[lord_kelvin->getName()] = lord_kelvin;

    // Miss Etikate Filter
    RFFilterCollection* miss_etikate = new RFFilterCollection("Katana");
    miss_etikate->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_miss_etikate = new RFTextureFilter("copy.vsh", "lookup.fsh", "lookup_miss_etikate.png", FLIPPED);
    lookup_miss_etikate->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_miss_etikate->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_miss_etikate->setup();
    miss_etikate->add_filter_framebuffer_pair(lookup_miss_etikate, iOS5_texture_fb);
    miss_etikate->add_filter_framebuffer_pair(copy, view_fb);
    corresp[miss_etikate->getName()] = miss_etikate;
    
    // Reddish Filter
    RFFilterCollection* reddish = new RFFilterCollection("Dharma");
    reddish->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_reddish = new RFTextureFilter("copy.vsh", "lookup_table.fsh", "red_green_table", red_green_table, 256, 3, FLIPPED);
    lookup_reddish->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_reddish->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_reddish->setup();
    reddish->add_filter_framebuffer_pair(lookup_reddish, texture_fb_2);
    RFFilter *multiply2 = new RFTextureFilter("copy.vsh", "color_burn.fsh", "sutroEdgeBurn.png", STRAIGHT);
    multiply2->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_2);
    multiply2->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    float screen_vec_reddish[4] = {1.0, 0, 0, 0.15};
    multiply2->bind_uniform_to_vec4_value("screen_vec", screen_vec_reddish);
    multiply2->setup();
    reddish->add_filter_framebuffer_pair(multiply2, iOS5_texture_fb);
    reddish->add_filter_framebuffer_pair(copy, view_fb);
    corresp[reddish->getName()] = reddish;
    
    //Greenish Filter
    RFFilterCollection* greenish = new RFFilterCollection("Koppar");
    greenish->add_filter_framebuffer_pair(crop, texture_fb_1);
    greenish->add_filter_framebuffer_pair(lookup_reddish, texture_fb_2);
    RFFilter *multiply3 = new RFTextureFilter("copy.vsh", "color_burn.fsh", "sutroEdgeBurn.png", STRAIGHT);
    multiply3->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_2);
    multiply3->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    float screen_vec_greenish[4] = {1.0, 1.0, 0, 0.15};
    multiply3->bind_uniform_to_vec4_value("screen_vec", screen_vec_greenish);
    multiply3->setup();
    greenish->add_filter_framebuffer_pair(multiply3, iOS5_texture_fb);
    greenish->add_filter_framebuffer_pair(copy, view_fb);
    corresp[greenish->getName()] = greenish;
    
    // Black and White
    RFFilterCollection* black_and_white = new RFFilterCollection("B&W");
    black_and_white->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *grayscale = new RFFilter("preview.vsh", "grayscale.fsh", FLIPPED);
    grayscale->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    grayscale->setup();
    black_and_white->add_filter_framebuffer_pair(grayscale, iOS5_texture_fb);
    black_and_white->add_filter_framebuffer_pair(copy, view_fb);
    corresp[black_and_white->getName()] = black_and_white;
    
    // Sepia Tone
    RFFilterCollection* sepia_tone = new RFFilterCollection("Sepia");
    sepia_tone->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *sepia = new RFFilter("preview.vsh", "sepia.fsh", FLIPPED);
    sepia->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    sepia->setup();
    sepia_tone->add_filter_framebuffer_pair(sepia, iOS5_texture_fb);
    sepia_tone->add_filter_framebuffer_pair(copy, view_fb);
    corresp[sepia_tone->getName()] = sepia_tone;
    
    // Amatorka Filter
    RFFilterCollection* amatorka = new RFFilterCollection("Beirut");
    amatorka->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *lookup_amatorka = new RFTextureFilter("copy.vsh", "lookup_table.fsh", "amatorke_table", amatorke_table, 256, 3, FLIPPED);
    lookup_amatorka->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    lookup_amatorka->bind_uniform_to_int_value("lookup_texture", LOOKUP_TEXTURE);
    lookup_amatorka->setup();
    amatorka->add_filter_framebuffer_pair(lookup_amatorka, iOS5_texture_fb);
    amatorka->add_filter_framebuffer_pair(copy, view_fb);
    corresp[amatorka->getName()] = amatorka;
    
    // Cartoon Filter
    RFFilterCollection* cartoon = new RFFilterCollection("Toon");
    cartoon->add_filter_framebuffer_pair(crop, texture_fb_1);
    RFFilter *blur = new RFFilter("preview.vsh", "blur.fsh");
    blur->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    blur->bind_uniform_to_float_value("texel_width",  1.f / TARGET_TEXTURE_WIDTH);
    blur->bind_uniform_to_float_value("texel_height", 1.f / TARGET_TEXTURE_HEIGHT);
    blur->setup();
    cartoon->add_filter_framebuffer_pair(blur, texture_fb_2);
    RFFilter *toon = new RFFilter("preview.vsh", "toon.fsh", FLIPPED);
    toon->bind_uniform_to_int_value("input_texture", OUTPUT_TEXTURE_1);
    toon->bind_uniform_to_int_value("blurred_texture", OUTPUT_TEXTURE_2);
    toon->bind_uniform_to_float_value("texel_width",  1.f / TARGET_TEXTURE_WIDTH);
    toon->bind_uniform_to_float_value("texel_height", 1.f / TARGET_TEXTURE_HEIGHT);
    toon->bind_uniform_to_float_value("coefficient", 1.0f);
    toon->setup();
    cartoon->add_filter_framebuffer_pair(toon, iOS5_texture_fb);
    cartoon->add_filter_framebuffer_pair(copy, view_fb);
    corresp[cartoon->getName()] = cartoon;
    
    NSString* file = [[NSBundle mainBundle] pathForResource:@"filters" ofType:@"plist"];
    NSArray* filtersInfo = [NSArray arrayWithContentsOfFile:file];
    
    for (NSDictionary* filterInfo in filtersInfo) {
        NSString *filterName = [filterInfo objectForKey:@"imageTitle"];
        const char* c_filter_name = [filterName cStringUsingEncoding:NSASCIIStringEncoding];
        filters.push_back(corresp[string(c_filter_name)]);
    }
}

void MyRenderer::render()
{
    filters.at(current_filter_index)->draw();
    RFRenderer::render();
}

void MyRenderer::useFilterNumber(int number)
{
    current_filter_index = number;
    NSLog(@"using new filter!!");
}

MyRenderer::~MyRenderer()
{
//    vector<RFFilterCollection*> filters;
//    vector<RFFramebuffer*>framebuffers;

    for (auto i = framebuffers.begin(); i != framebuffers.end(); ++i) {
        delete *i;
    }
    for (auto i = filters.begin(); i != filters.end(); ++i) {
        delete *i;
    }
}