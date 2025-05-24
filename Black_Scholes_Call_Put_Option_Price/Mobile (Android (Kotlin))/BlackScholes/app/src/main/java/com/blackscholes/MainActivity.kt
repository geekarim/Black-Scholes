package com.blackscholes

import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.activity.compose.setContent
import com.blackscholes.ui.theme.BlackScholesTheme

class MainActivity : AppCompatActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Theme
        setContent {
            BlackScholesTheme {
                // Jetpack Compose screen
                BlackScholesScreen()
            }
        }
    }
}
