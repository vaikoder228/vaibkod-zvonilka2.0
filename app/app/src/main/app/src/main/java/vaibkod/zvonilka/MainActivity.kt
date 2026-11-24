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
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
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
    
    // Запрос разрешений при запуске
    val permissionLauncher = rememberLauncherForActivityResult(
        ActivityResultContracts.RequestMultiplePermissions()
    ) { permissions ->
        val callGranted = permissions[Manifest.permission.CALL_PHONE] ?: false
        if (!callGranted) {
            Toast.makeText(context, "Без разрешения на звонки не работает!", Toast.LENGTH_LONG).show()
        }
    }

    LaunchedEffect(Unit) {
        permissionLauncher.launch(
            arrayOf(
                Manifest.permission.CALL_PHONE,
                Manifest.permission.READ_CONTACTS,
                Manifest.permission.READ_CALL_LOG
            )
        )
    }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Заголовок
        Text(
            text = "Звонилка Вайбкодера",
            fontSize = 28.sp,
            fontWeight = FontWeight.Bold,
            color = Color(0xFF00FFCC), // Наш вайбкод цвет
            modifier = Modifier.padding(top = 32.dp, bottom = 16.dp)
        )

        // Поле для ввода номера
        OutlinedTextField(
            value = phoneNumber,
            onValueChange = { phoneNumber = it },
            label = { Text("Введите номер") },
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 32.dp),
            shape = RoundedCornerShape(16.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = Color(0xFF00FFCC),
                focusedLabelColor = Color(0xFF00FFCC)
            )
        )

        // Кнопка позвонить
        Button(
            onClick = {
                if (phoneNumber.isNotBlank()) {
                    val intent = Intent(Intent.ACTION_CALL).apply {
                        data = Uri.parse("tel:$phoneNumber")
                    }
                    if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE) == PackageManager.PERMISSION_GRANTED) {
                        context.startActivity(intent)
                    } else {
                        Toast.makeText(context, "Нет разрешения на звонок", Toast.LENGTH_SHORT).show()
                    }
                } else {
                    Toast.makeText(context, "Введи номер!", Toast.LENGTH_SHORT).show()
                }
            },
            modifier = Modifier
                .size(80.dp),
            shape = CircleShape,
            colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF00FFCC))
        ) {
            Icon(
                imageVector = Icons.Default.Call,
                contentDescription = "Позвонить",
                tint = Color.Black,
                modifier = Modifier.size(40.dp)
            )
        }

        Spacer(modifier = Modifier.weight(1f))

        // Нижняя панель с ярлыком диктофона и контактов
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(bottom = 32.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            // Кнопка Диктофон (Запись звонка)
            FloatingActionButton(
                onClick = {
                    try {
                        // Пытаемся открыть системный диктофон (ColorOS/Oppo/OnePlus)
                        val intent = Intent(Intent.ACTION_MAIN).apply {
                            addCategory(Intent.CATEGORY_LAUNCHER)
                            setClassName("com.coloros.soundrecorder", "com.coloros.soundrecorder.SoundRecorder")
                        }
                        context.startActivity(intent)
                    } catch (e: Exception) {
                        try {
                            // Запасной вариант, если вдруг не нашли
                            val intent = Intent(Intent.ACTION_VIEW)
                            intent.type = "audio/*"
                            context.startActivity(Intent.createChooser(intent, "Открыть диктофон"))
                        } catch (e2: Exception) {
                            Toast.makeText(context, "Диктофон не найден", Toast.LENGTH_SHORT).show()
                        }
                    }
                },
                containerColor = MaterialTheme.colorScheme.surfaceVariant
            ) {
                Icon(Icons.Default.Mic, contentDescription = "Диктофон", tint = Color.White)
            }

            // Кнопка Контакты
            FloatingActionButton(
                onClick = {
                    val intent = Intent(Intent.ACTION_VIEW, Uri.parse("content://contacts/people/"))
                    context.startActivity(intent)
                },
                containerColor = MaterialTheme.colorScheme.surfaceVariant
            ) {
                Icon(Icons.Default.Person, contentDescription = "Контакты", tint = Color.White)
            }
        }
    }
}
