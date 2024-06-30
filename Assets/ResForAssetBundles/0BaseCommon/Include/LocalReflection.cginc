#ifndef LOCAL_REFLECTION
#define  LOCAL_REFLECTION

float3 _LocalCubePos;
half3 _EnvMapOffset;
#if CORRECT_BOX
half3 _BoxMin;
half3 _BoxMax;
#endif
#if CORRECT_CYLINDER
half _Radius;
float3 _GeometryCenter;
#endif

float3 LocalCorrectBox(float3 origVec, float3 bboxMin, float3 bboxMax, float3 vertexPos, float3 cubemapPos)
{
	// Find the ray intersection with box plane
	float3 invOrigVec = float3(1.0, 1.0, 1.0) / origVec;
	float3 intersecAtMaxPlane = (bboxMax - vertexPos) * invOrigVec;
	float3 intersecAtMinPlane = (bboxMin - vertexPos) * invOrigVec;
	// Get the largest intersection values (we are not intersted in negative values)
	float3 largestIntersec = max(intersecAtMaxPlane, intersecAtMinPlane);
	// Get the closest of all solutions
	float Distance = min(min(largestIntersec.x, largestIntersec.y), largestIntersec.z);
	// Get the intersection position
	float3 IntersectPositionWS = vertexPos + origVec * Distance;
	// Get corrected vector
	float3 localCorrectedVec = IntersectPositionWS - cubemapPos;
	return localCorrectedVec;
}

half3 LocalCorrectSphere(half3 rayDir, half3 rayOrigin, half3 sphereCenter, float sphereRadius)
{
	half3 offset = sphereCenter - rayOrigin;
	float rayDist = dot(rayDir, offset);

	float off2 = dot(offset, offset);
	float rad2 = sphereRadius * sphereRadius;

	float d = sqrt(rad2 - (off2 - rayDist * rayDist));

	float hitDistance = rayDist < 0 ? d - (-rayDist) : d + rayDist;
	half3 hitPoint = rayOrigin + rayDir * hitDistance;

	return hitPoint - sphereCenter;
}


float3 LocalCorrectSphereFast(float3 origVec, float3 pixelPos, float3 cubemapPos, float radius)
{
	float3 localCorrectedVec = _EnvMapOffset * (pixelPos - cubemapPos) + origVec;
	//float3 localCorrectedVec  = (1.0/radius) * (pixelPos - cubemapPos) + origVec;
	return localCorrectedVec;
}

half3 LocalCorrectCylinder(half3 rayDir, half3 rayOrigin, half3 sphereCenter, float sphereRadius, float3 cubeCenter)
{
	half3 newRayDir = normalize(half3(rayDir.x, 0, rayDir.z));
	half3 newSphereCenter = half3(sphereCenter.x, rayOrigin.y, sphereCenter.z);
	half3 offset = newSphereCenter - rayOrigin;
	half rayDist = dot(newRayDir, offset);

	half off2 = dot(offset, offset);
	half rad2 = sphereRadius * sphereRadius;


	if (rad2 - off2 < 0)
	{
		return rayDir;
	}

	// find hit distance squared
// ray passes by sphere without hitting
	half d = sqrt(rad2 - (off2 - rayDist * rayDist));

	half hitDistance = rayDist < 0 ? d - (-rayDist) : d + rayDist;
	half3 hitPoint = rayOrigin + newRayDir * hitDistance;
	//float thelta = 90 - half3.Angle(half3.up, rayDir);
	//float height = hitDistance * Mathf.Tan(thelta * Mathf.Deg2Rad);

	half sin = dot(half3(0, 1, 0), rayDir);
	half tan = sin / sqrt((1 - sin * sin));
	float height = hitDistance * tan;

	return hitPoint + height * half3(0, 1, 0) - cubeCenter;
}
#endif
