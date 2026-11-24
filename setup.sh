#!/bin/bash
mkdir -p app/src/main/java/vaibkod/zvonilka
mkdir -p app/src/main

# Создаем build.gradle.kts
cat << 'EOF' > app/build.gradle.kts
plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
}
android {
    namespace = "vaibkod.zvonilka"
    compileSdk = 34
    defaultConfig {
        applicationId = "vaibkod.zvonilka"
        minSdk = 26
        targetSdk = 34
        versionCode = 1
        versionName = "1.0"
    }
    buildTypes {
        release {
            isMinifyEnabled = false
        }
    }
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }
    kotlinOptions {
        jvmTarget = "1.8"
    }
    buildFeatures {
        compose = true
    }
    composeOptions {
        kotlinCompilerExtensionVersion = "1.5.8"
    }
}
dependencies {
    implementation("androidx.core:core-ktx:1.12.0")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.7.0")
    implementation("androidx.activity:activity-compose:1.8.2")
    implementation(platform("androidx.compose:compose-bom:2024.02.00"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-graphics")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.appcompat:appcompat:1.6.1")
}
EOF

# Создаем AndroidManifest.xml
cat << 'EOF' > app/src/main/AndroidManifest.xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <uses-permission android:name="android.permission.CALL_PHONE" />
    <uses-permission android:name="android.permission.READ_CONTACTS" />
    <uses-permission android:name="android.permission.READ_CALL_LOG" />
    <application
        android:allowBackup="true"
        android:icon="@android:drawable/ic_menu_call"
        android:label="Звонилка Вайбкодера"
        android:theme="@style/Theme.AppCompat.DayNight.NoActionBar">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
            <intent-filter>
                <action android:name="android.intent.action.DIAL" />
                <category android:name="android.intent.category.DEFAULT" />
                <data android:scheme="tel" />
            </intent-filter>
        </activity>
    </application>
</manifest>
EOF

# Создаем MainActivity.kt
cat << 'EOF' > app/src/main/java/vaibkod/zvonilka/MainActivity.kt
package vaibkod.zvonilka

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.widget.Toast
import androidx.activity.ComponentActivity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.compose.setContent
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Call
import androidx.compose.material.icons.filled.Mic
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.core.content.ContextCompat

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme(colorScheme = darkColorScheme()) {
                Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                    ZvonilkaScreen()
                }
            }
        }
    }
}

@Composable
fun ZvonilkaScreen() {
    val context = LocalContext.current
    var phoneNumber by remember { mutableStateOf("") }
    val permissionLauncher = rememberLauncherForActivityResult(ActivityResultContracts.RequestMultiplePermissions()) { permissions ->
        val callGranted = permissions[Manifest.permission.CALL_PHONE] ?: false
        if (!callGranted) Toast.makeText(context, "Без разрешения на звонки не работает!", Toast.LENGTH_LONG).show()
    }
    LaunchedEffect(Unit) {
        permissionLauncher.launch(arrayOf(Manifest.permission.CALL_PHONE, Manifest.permission.READ_CONTACTS, Manifest.permission.READ_CALL_LOG))
    }
    Column(modifier = Modifier.fillMaxSize().padding(16.dp), horizontalAlignment = Alignment.CenterHorizontally) {
        Text(text = "Звонилка Вайбкодера", fontSize = 28.sp, fontWeight = FontWeight.Bold, color = Color(0xFF00FFCC), modifier = Modifier.padding(top = 32.dp, bottom = 16.dp))
        OutlinedTextField(value = phoneNumber, onValueChange = { phoneNumber = it }, label = { Text("Введите номер") }, modifier = Modifier.fillMaxWidth().padding(bottom = 32.dp), shape = RoundedCornerShape(16.dp), colors = OutlinedTextFieldDefaults.colors(focusedBorderColor = Color(0xFF00FFCC), focusedLabelColor = Color(0xFF00FFCC)))
        Button(onClick = {
            if (phoneNumber.isNotBlank()) {
                val intent = Intent(Intent.ACTION_CALL).apply { data = Uri.parse("tel:$phoneNumber") }
                if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) context.startActivity(intent) else Toast.makeText(context, "Нет разрешения", Toast.LENGTH_SHORT).show()
            } else Toast.makeText(context, "Введи номер!", Toast.LENGTH_SHORT).show()
        }, modifier = Modifier.size(80.dp), shape = CircleShape, colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00FFCC))) {
            Icon(imageVector = Icons.Default.Call, contentDescription = "Позвонить", tint = Color.Black, modifier = Modifier.size(40.dp))
        }
        Spacer(modifier = Modifier.weight(1f))
        Row(modifier = Modifier.fillMaxWidth().padding(bottom = 32.dp), horizontalArrangement = Arrangement.SpaceEvenly) {
            FloatingActionButton(onClick = {
                try {
                    val intent = Intent(Intent.ACTION_MAIN).apply { addCategory(Intent.CATEGORY_LAUNCHER); setClassName("com.coloros.soundrecorder", "com.coloros.soundrecorder.SoundRecorder") }
                    context.startActivity(intent)
                } catch (e: Exception) { Toast.makeText(context, "Диктофон не найден", Toast.LENGTH_SHORT).show() }
            }, containerColor = MaterialTheme.colorScheme.surfaceVariant) { Icon(Icons.Default.Mic, contentDescription = "Диктофон", tint = Color.White) }
            FloatingActionButton(onClick = { context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("content://contacts/people/"))) }, containerColor = MaterialTheme.colorScheme.surfaceVariant) { Icon(Icons.Default.Person, contentDescription = "Контакты", tint = Color.White) }
        }
    }
}
EOF

# Настройка сборки
sed -i 's/include(":app")/include(":app")/' settings.gradle.kts
sed -i 's/gradle assembleDebug/bash setup.sh \&\& gradle assembleDebug/' .github/workflows/build.yml
