package com.blackscholes

import android.widget.Toast
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.text.selection.TextSelectionColors
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.TextFieldColors
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.input.KeyboardType

@Composable
fun BlackScholesScreen() {
    val context = LocalContext.current
    var S by remember { mutableStateOf("") }
    var K by remember { mutableStateOf("") }
    var r by remember { mutableStateOf("") }
    var T by remember { mutableStateOf("") }
    var sigma by remember { mutableStateOf("") }
    var result by remember { mutableStateOf<Pair<Double, Double>?>(null) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(16.dp),
    ) {
        OutlinedTextField(value = S,
            onValueChange = {
                if (it.matches(Regex("^\\d*\\.?\\d*\$"))) {
                    S = it
                }
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            label = { Text("Stock Price") }, placeholder = { Text("Stock Price", color = Color.Gray) })
        OutlinedTextField(value = K,
            onValueChange = {
                if (it.matches(Regex("^\\d*\\.?\\d*\$"))) {
                    K = it
                }
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            label = { Text("Strike Price") }, placeholder = { Text("Strike Price", color = Color.Gray) })
        OutlinedTextField(value = r,
            onValueChange = {
                if (it.matches(Regex("^\\d*\\.?\\d*\$"))) {
                    r = it
                }
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            label = { Text("Interest Rate") }, placeholder = { Text("Stock Price", color = Color.Gray) })
        OutlinedTextField(value = T,
            onValueChange = {
                if (it.matches(Regex("^\\d*\\.?\\d*\$"))) {
                    T = it
                }
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            label = { Text("Time to Maturity") }, placeholder = { Text("Stock Price", color = Color.Gray) })
        OutlinedTextField(value = sigma,
            onValueChange = {
                if (it.matches(Regex("^\\d*\\.?\\d*\$"))) {
                    sigma = it
                }
            },
            keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
            label = { Text("Volatility") }, placeholder = { Text("Stock Price", color = Color.Gray) })

        Spacer(modifier = Modifier.height(16.dp))

        Button(onClick = {
            try {
                val callPut = BlackScholesCalculator.blackScholesCallPutOptionPrice(
                    S.toDouble(), K.toDouble(), r.toDouble(), T.toDouble(), sigma.toDouble()
                )
                result = callPut
            } catch (e: Exception) {
                Toast.makeText(context, "Invalid input", Toast.LENGTH_SHORT).show()
            }
        }) {
            Text("Calculate")
        }

        result?.let {
            Text("Call Price: ${it.first}", color = Color.White, style = MaterialTheme.typography.bodyLarge)
            Text("Put Price: ${it.second}", color = Color.White, style = MaterialTheme.typography.bodyLarge)
        }
    }
}
